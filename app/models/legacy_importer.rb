#
# This class provides methods that handle import from ultimate for Repositories
# and Collections.
#
class LegacyImporter

  @logger = Logger.new('./log/repo_and_coll_import.log')

  THUMBNAIL_ROOT = 'https://dlg.galileo.usg.edu/do-th:'.freeze

  def self.create_repository(repo_hash)

    repo_hash = repo_hash['repo']

    repository = Repository.new

    portals = repo_hash.delete 'portals'
    color = repo_hash.delete 'color'

    repository.update repo_hash

    repository.color = "##{color}" if color && !color.empty?
    repository.thumbnail_path = "#{THUMBNAIL_ROOT}#{repository.slug}"

    assign_portals repository, portals

    repository.save(validate: false)
    repository

  end

  def self.create_collection(collection_hash)

    collection_hash = collection_hash['coll']
    repository_hash = collection_hash.delete('repository')

    unless repository_hash
      @logger.error "No Repository info for #{collection_hash['slug']}."
      return false
    end

    collection = Collection.find_by_record_id("#{repository_hash['slug']}_#{collection_hash['slug']}")

    unless collection
      collection = Collection.new
      if repository_hash.key?('slug')
        collection.repository = Repository.find_by_slug repository_hash['record_id']
      else
        @logger.error "No Repository could be set for collection #{collection_hash['slug']}."
      end
    end

    collection_hash['display_title'] ||= collection_hash['dcterms_title'].first

    local = collection_hash.delete('local')
    color = collection_hash.delete('color')
    collection.color = "##{color}" if color && !color.empty?

    assign_portals collection, collection_hash.delete('portals')
    assign_time_periods collection, collection_hash.delete('time_period')
    assign_topics collection, collection_hash.delete('topic')
    assign_other_repositories collection, collection_hash.delete('other_repository')

    if repository_hash && repository_hash.key?('slug') && !collection.repository
      collection.repository = Repository.find_by_slug repository_hash['slug']
    end

    collection.update collection_hash
    collection.save(validate: false)
    collection

  end

  def self.assign_portals(object, portals_hash)
    portals_hash.each do |portal_data|
      portal = Portal.find_by_code portal_data['code']
      object.portals << portal if portal
    end if portals_hash
  end

  def self.assign_time_periods(object, time_periods_hash)
    time_periods_hash.each do |xml_tp|
      xml_tp.gsub!('Millenium', 'Millennium')
      TimePeriod.all.each do |tp|
        if xml_tp.index(tp.name)
          object.time_periods << tp
          next
        end
      end
    end if time_periods_hash
  end

  def self.assign_topics(object, topics_hash)
    topics_hash.each do |s|
      subj = Subject.find_by_name s
      object.subjects << subj if subj
    end if topics_hash
  end

  def self.assign_other_repositories(object, other_repos_hash)
    other_repos_hash.each do |r|
      other_repository = Repository.find_by_slug(r)
      object.other_repositories << other_repository.id if other_repository
    end if other_repos_hash
  end

end