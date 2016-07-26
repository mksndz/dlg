require 'rake'
require 'open-uri'
require 'nokogiri'

task import_repositories: :environment do

  @logger = Logger.new('./log/repo_and_coll_import.log')

  start_time = Time.now

  def exit_with_error(msg = nil)
    @logger.error msg || 'Something unexpected happened...'
    puts 'Task aborted due to an error. Check the logs!'
    abort
  end

  # START TASK

  repositories_created = 0
  collections_created  = 0

  repo_node_name                = 'repo'.freeze
  collection_section_node_name  = 'colls'.freeze
  collection_node_name          = 'coll'.freeze
  slug_node_name                = 'code'.freeze
  name_node_name                = 'name'.freeze

  # define sources
  repository_hierarchy_source   = 'http://dlg.galileo.usg.edu/xml/dcq/Collections.xml'.freeze
  repository_metadata_source    = 'http://dlg.galileo.usg.edu/xml/dcq/repos.xml'.freeze

  @logger.info "Importing Repositories from Legacy META UltimateDB @ #{repository_hierarchy_source}"
  @logger.info "Using Repository Metadata from UltimateDB @ #{repository_metadata_source}"

  # open sources
  repo_hierarchy_file = open repository_hierarchy_source
  repo_metadata_file  = open repository_metadata_source

  @hierarchy_data = Nokogiri::XML repo_hierarchy_file
  @repo_metadata  = Nokogiri::XML repo_metadata_file

  exit_with_error "Could'nt get valid XML from #{repository_hierarchy_source}" unless @hierarchy_data.is_a? Nokogiri::XML::Document
  exit_with_error "Could'nt get valid XML from #{repository_metadata_source}" unless @repo_metadata.is_a? Nokogiri::XML::Document

  # close files
  repo_hierarchy_file.close
  repo_metadata_file.close

  # get some numbers
  repos_in_hfile = @hierarchy_data.css repo_node_name
  colls_in_hfile = @hierarchy_data.css(collection_section_node_name).css(collection_node_name)
  repos_in_mfile = @repo_metadata.css repo_node_name

  @logger.info "Repositories included in hierarchy file: #{repos_in_hfile.length}"
  @logger.info "Collections included in hierarchy file: #{repos_in_mfile.length}"
  @logger.info "Repositories included in metadata file: #{repos_in_mfile.length}"

  exit_with_error 'No Repositories found in the hierarchy file :(' if repos_in_hfile.empty?
  exit_with_error 'No Collection Data found in the hierarchy file :(' if colls_in_hfile.empty?
  exit_with_error 'No Repositories found in the metadata file :(' if repos_in_mfile.empty?

  # PUT HIERARCHY DATA INTO HASH

  # establish hash of collections slugs and corresponding names
  names_hash = {}
  colls_in_hfile.each do |c|
    name = c.css(name_node_name).inner_text
    names_hash[c.css(slug_node_name).inner_text] = name unless name.empty?
  end

  # establish hash with repo slugs and collection slugs (slug and title)
  structure_hash = {}
  repos_in_hfile.each do |repo_node|
    coll_array = []
    collection_section = repo_node.css(collection_section_node_name).first
    collection_section.css(collection_node_name).each do |coll|
      coll_info = {}
      slug = coll.css(slug_node_name).inner_text
      coll_info[:slug] = slug
      coll_info[:name] = names_hash[slug]
      coll_array.push coll_info
    end
    structure_hash[repo_node.css(slug_node_name)[0].inner_text] = coll_array
  end

  # REPO PROCESSING

  # start looping through metadata file
  repos_in_mfile.each do |repo_node|
    # create or update repository
    repository = LegacyImporter.create_or_update_repository repo_node
    # set collection relations
    if repository
      @logger.info "Repository created: #{repository.title}"
      collections_count = LegacyImporter.create_repository_collections repository, structure_hash[repository.slug]
      collections_created += collections_count
      @logger.info "Collections created within repository: #{collections_count}"
      repositories_created += 1
    else
      @logger.error "Could not create repository: #{slug}"
    end

  end

  Sunspot.commit_if_dirty

  puts 'Repository import complete!'
  @logger.info "Processing took #{Time.now - start_time} seconds!"
  @logger.info "Repositories created #{repositories_created}"
  @logger.info "Collections created #{collections_created}"

end