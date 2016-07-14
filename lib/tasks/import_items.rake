require 'rake'
require 'open-uri'
require 'nokogiri'
task :import_items, [:collection_slug] => [:environment] do |t, args|

  importer = LegacyImporter.new

  @logger = Logger.new('./log/item_import.log')

  def exit_with_error(msg = nil)
    @logger.info msg || 'Something unexpected happened...'
    abort
  end

  def get_solr_hits_for_collection(collection)
    s = Item.search do
      with(:collection_id, collection.id)

      adjust_solr_params do |params|
        params[:q] = ''
      end
    end
    s.total
  end

  start_time = Time.now

  if defined?(args) && args[:collection_slug]
    collection = Collection.find_by_slug(args[:collection_slug])
    if collection
      collections = [collection]
      @logger.info "Designated Collection to load: #{collections.first.slug}"
    else
      exit_with_error('Error loading the Collection you specified: ' + args[:collection_slug])
    end
  else
    collections = Collection.all
  end

  @logger.info 'Clearing out old Items...'
  Item.destroy_all
  Sunspot.commit_if_delete_dirty
  @logger.info 'Items destroyed!'

  s = Item.search do
    adjust_solr_params do |params|
      params[:q] = ''
    end
  end

  @logger.info "Starting Item Count: #{Item.all.length}"
  @logger.info "Starting Solr Count: #{s.total}"

  meta_xml_root_url = 'http://dlg.galileo.usg.edu/xml/dcq/'

  exit_with_error 'No Repositories yet in the system!' unless Repository.first
  exit_with_error 'No Collection yet in the system!' unless Collection.first

  collections.each do |collection|

    xml_url = "#{meta_xml_root_url}#{collection.repository.slug}_#{collection.slug}.xml"

    # queue Collection for Adding and Indexing
    LegacyImporter.delay.collection(collection, xml_url)

    @logger.info "Collection #{collection.display_title} quered for loading."

  end

  finish_time = Time.now

  @logger.info 'Item importing complete!'
  @logger.info "Processing took #{finish_time - start_time} seconds!"

end