require 'rake'
require 'open-uri'
require 'nokogiri'

task import_repositories: :environment do

  @logger = Logger.new('./log/repo_and_coll_import.log')

  start_time = Time.now

  def exit_with_error(msg = nil)
    @logger.error msg || 'Something unexpected happened...'
    puts "#{msg} The logs may have more info."
    abort
  end

  # Require empty Meta

  exit_with_error 'Repositories already exist in the system. Clear them out if you want to run this process.' if Repository.first
  exit_with_error 'Collections already exist in the system. Clear them out if you want to run this process.' if Collection.first

  # START TASK

  repositories_created = 0
  collections_created  = 0

  repo_node_name                = 'repo'.freeze
  collection_section_node_name  = 'colls'.freeze
  collection_node_name          = 'coll'.freeze
  slug_node_name                = 'code'.freeze
  name_node_name                = 'name'.freeze
  portal_node_name              = 'portal'.freeze

  # define sources
  repository_hierarchy_source   = 'http://dlg.galileo.usg.edu/xml/dcq/Collections.xml'.freeze
  repository_metadata_source    = 'http://dlg.galileo.usg.edu/xml/dcq/repos.xml'.freeze
  collection_metadata_source    = 'http://dlg.galileo.usg.edu/xml/dcq/colls.xml'.freeze

  @logger.info "Importing Repositories from Legacy META UltimateDB @ #{repository_hierarchy_source}."
  @logger.info "Using Repository Metadata from UltimateDB @ #{repository_metadata_source}."
  @logger.info "Using Collection Metadata from UltimateDB @ #{collection_metadata_source}."

  # open sources
  repo_hierarchy_file = open repository_hierarchy_source
  repo_metadata_file  = open repository_metadata_source
  coll_metadata_file  = open collection_metadata_source

  @hierarchy_data = Nokogiri::XML repo_hierarchy_file
  @repo_metadata  = Nokogiri::XML repo_metadata_file
  @coll_metadata  = Nokogiri::XML coll_metadata_file

  exit_with_error "Could'nt get valid XML from #{repository_hierarchy_source}." unless @hierarchy_data.is_a? Nokogiri::XML::Document
  exit_with_error "Could'nt get valid XML from #{repository_metadata_source}." unless @repo_metadata.is_a? Nokogiri::XML::Document
  exit_with_error "Could'nt get valid XML from #{collection_metadata_source}." unless @coll_metadata.is_a? Nokogiri::XML::Document

  # close files
  repo_hierarchy_file.close
  repo_metadata_file.close
  coll_metadata_file.close

  # get some numbers
  repos_in_hfile = @hierarchy_data.css repo_node_name
  colls_in_hfile = @hierarchy_data.css(collection_section_node_name).css(collection_node_name)
  repos_in_mfile = @repo_metadata.css repo_node_name
  colls_in_mfile = @coll_metadata.css collection_node_name

  exit_with_error 'No Repositories found in the hierarchy file.' if repos_in_hfile.empty?
  exit_with_error 'No Collection Data found in the hierarchy file.' if colls_in_hfile.empty?
  exit_with_error 'No Repositories found in the metadata file.' if repos_in_mfile.empty?
  exit_with_error 'No Collections found in the metadata file.' if colls_in_mfile.empty?

  @logger.info "Repositories included in hierarchy file: #{repos_in_hfile.length}."
  @logger.info "Collections included in hierarchy file: #{repos_in_mfile.length}."
  @logger.info "Repositories included in metadata file: #{repos_in_mfile.length}."
  @logger.info "Collection included in metadata file: #{colls_in_mfile.length}."

  # PUT HIERARCHY DATA INTO HASH

  # establish hash of collections slugs and corresponding names
  names_hash = {}
  colls_in_hfile.each do |c|
    name = c.css(name_node_name).inner_text
    slug = c.css(slug_node_name).inner_text
    if name && slug
      names_hash[slug] = name
    else
      @logger.warn "Problem extracting data for names hash: #{name} && #{slug}."
    end
  end

  # establish hash with repo slugs and collection slug and title
  structure_hash = {}
  repos_in_hfile.each do |repo_node|
    repo_slug = repo_node.css(slug_node_name)[0].inner_text
    if repo_slug
      coll_array = []
      collection_section = repo_node.css(collection_section_node_name).first
      collection_section.css(collection_node_name).each do |coll|
        coll_info = {}
        slug = coll.css(slug_node_name).inner_text
        coll_info[:slug] = slug
        coll_info[:name] = names_hash[slug]
        coll_array.push coll_info
      end
      structure_hash[repo_slug] = coll_array
    else
      @logger.warn "Problem extracting a repo slug from a node!: #{repo_node}."
    end
  end

  # REPO PROCESSING

  # start looping through metadata file
  repos_in_mfile.each do |repo_node|
    # create repository
    repository = LegacyImporter.create_repository repo_node

    # set collection relations
    if repository
      @logger.info "Repository added: #{repository.title}."
      repositories_created += 1
    else
      @logger.error "Could not create repository: #{slug}."
    end

    # set portal membership
    portals_node = repo_node.css(portal_node_name)
    LegacyImporter.set_portals repository, portals_node

  end

  # COLLECTION METADATA PROCESSING

  colls_in_mfile.each do |coll_node|
    collection = LegacyImporter.create_collection coll_node
    if collection
      @logger.info "Collection added: #{collection.display_title}."
      collections_created += 1

      # set portals
      LegacyImporter.set_portals collection, coll_node.css(portal_node_name)

    end
  end

  # REPORT AND REMOVE ANY COLLECTIONS WITHOUT REPOSITORIES

  Collection.find_each(batch_size: 100) do |c|
    unless c.repository
      @logger.error "Collection without Repository found: #{c.display_title}. Will destroy."
      c.destroy
    end
  end

  Sunspot.commit_if_dirty

  puts 'Repository import complete!'
  @logger.info "Processing took #{Time.now - start_time} seconds!"
  @logger.info "Repositories created: #{repositories_created}."
  @logger.info "Collections created: #{collections_created}."

end