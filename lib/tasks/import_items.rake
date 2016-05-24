require 'rake'
require 'open-uri'
require 'nokogiri'

task :import_items, [:collection_slug] => [:environment] do |t, args|

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
      exit_with_error('Error loading the Collection you specified')
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

    items_created = 0

    collection_start_time = Time.now

    xml_url = "#{meta_xml_root_url}#{collection.repository.slug}_#{collection.slug}.xml"
    @logger.info "Importing Items from XML: #{xml_url}"

    @data = Nokogiri::HTML(open(xml_url))

    unless @data.is_a? Nokogiri::HTML::Document
      exit_with_error "Could'nt get valid XML from #{data_source}"
    end

    items = @data.css('item')

    items.each do |item|

      hash = Hash.from_xml(item.to_s)

      item_hash = hash['item']

      item_hash.delete('collection')
      item_hash.delete('dc_identifier_label')
      other_collections = item_hash.delete('other_collection')

      i = Item.new(item_hash)
      i.collection = collection

      if other_collections
        other_collections.each do |oc|
          i.other_collections << Collection.find_by_slug(oc).id
        end
      end

      @logger.info other_collections.inspect
      @logger.info i.other_collections.inspect

      i.save(validate: false)

      items_created += 1

    end

    Sunspot.commit_if_dirty

    @logger.info "Collection #{collection.title} Items Created: #{items_created}"
    @logger.info "Collection #{collection.title} Items In XML: #{items.length}"
    @logger.info "Solr now has #{get_solr_hits_for_collection collection} records for this collection"

    collection_finish_time = Time.now

    @logger.info "Importing #{xml_url} took #{collection_finish_time - collection_start_time} seconds!"
  end

  finish_time = Time.now

  @logger.info 'Item importing complete!'
  @logger.info "Processing took #{finish_time - start_time} seconds!"

end