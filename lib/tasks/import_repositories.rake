require 'rake'
require 'open-uri'
require 'nokogiri'

task import_repositories: :environment do

  start_time = Time.now

  def exit_with_error(msg = nil)
    puts msg || 'Something unexpected happened...'
    abort
  end

  def process_collections_for(repo, r)
    collections = r.css('coll')
    puts "Repo has #{collections.length} collections included"
    collections.each do |c|
      coll_code = c.css('code').first.inner_text
      coll_title = c.css('name').first ? c.css('name').first.inner_text : 'REPLACE'
      coll = Collection.find_by_slug(coll_code)

      if coll
        puts "Existing collection with code #{coll_code} found. Updating values."
        coll.slug = coll_code
        coll.display_title = coll_title
      else
        coll = Collection.new(slug: coll_code, display_title: coll_title)
      end
      coll.repository = repo
      if coll.save
        puts "Collection with slug #{coll_code} processed!"
        @collections_created += 1
      else
        puts "Problem saving collection with slug #{coll_code}."
        @problem_collections += 1
      end
    end
  end

  def set_collection_titles
    collection_section = @data.css('colls')[0]
    collection_section.css('coll').each do |c|
      slug = c.css('code').first.inner_text
      title = c.css('name').first.inner_text
      coll = Collection.find_by_slug(slug)
      if coll
        coll.display_title = title
        coll.save
        puts "Collection title set to #{title} for collection with slug #{slug}"
      end
    end
  end

  repository_source = 'http://dlg.galileo.usg.edu/xml/dcq/Collections.xml'
  puts "Importing Repositories from Legacy META UltimateDB @ #{repository_source}"
  @data = Nokogiri::HTML(open(repository_source))

  unless @data.is_a? Nokogiri::HTML::Document
    exit_with_error "Could'nt get valid XML from #{data_source}"
  end

  repositories = @data.css('repo')
  puts "Repositories included in file: #{repositories.length}"

  if repositories.empty?
    exit_with_error 'No Repositories found in the file :('
  end

  @repos_created = 0
  @collections_created = 0
  @problem_repos = 0
  @problem_collections = 0

  repositories.each do |r|
    name = r.css('name').first.inner_text
    code = r.css('code').first.inner_text
    repo = Repository.find_by_slug(code)
    if repo
      puts "Existing repo with code #{code} found. Updating values."
      repo.slug = code
      repo.title = name
    else
      repo = Repository.new({slug: code, title: name})
    end

    if repo.save
      puts "Repo with slug #{code} processed!"
      @repos_created += 1
      process_collections_for repo, r
    else
      puts "Problem saving repo with slug #{code}."
      @problem_repos += 1
    end
  end

  set_collection_titles

  finish_time = Time.now

  puts 'File processing complete!'
  puts "Processing took #{finish_time - start_time} seconds!"
  puts "Repositories processed: #{@repos_created}"
  puts "Collections processed: #{@collections_created}"
  puts "Repositories unsaved due to issues: #{@problem_repos}"
  puts "Collections unsaved due to issues: #{@problem_collections}"

end