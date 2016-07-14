class LegacyImporter

  @logger = Logger.new('./log/item_import.log')

  # Import a collection
  # @string slug
  # @string xml_url
  def self.collection(collection, xml_url)

    unless collection.is_a? Collection
      @logger.error 'collection is not a Collection'
      return false
    end

    if xml_url.empty?
      @logger.error 'No xml url provided'
      return false
    end

    items_created = 0

    collection_start_time = Time.now

    @logger.info "Importing Items from XML: #{xml_url}"

    @data = Nokogiri::HTML(open(xml_url))

    unless @data.is_a? Nokogiri::HTML::Document
      @logger.error "Could'nt get valid XML from #{data_source}"
      return false
    end

    items = @data.css('item')

    items_to_add = items.length

    @logger.info "XML for #{collection.display_title} has #{items.length} to add"

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
          other_collection = Collection.find_by_slug(oc)
          if other_collection
            i.other_collections << other_collection.id
          else
            @logger.error "No Collection with slug #{oc} found to add to other_collection array for item #{i.record_id}."
          end
        end
      end

      begin
        i.save(validate: false)
      rescue => e
        @logger.error "Item #{i.record_id} could not be saved: #{e.message}"
      end

    end

    Sunspot.commit

    @logger.info "Collection #{collection.title} Items Created: #{items_created}"
    @logger.info "Collection #{collection.title} Items In XML: #{items.length}"

    collection_finish_time = Time.now

    @logger.info "Importing #{xml_url} took #{collection_finish_time - collection_start_time} seconds!"

  end

end