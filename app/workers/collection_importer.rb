class CollectionImporter

  @queue = :items
  @logger = Logger.new('./log/item_import.log')

  def self.perform(collection_id, items_xml_url)

    item_node_name = 'item'.freeze

    begin
      xml_file = open items_xml_url
    rescue StandardError => e
      @logger.info "Could not get XML from provided URL(#{items_xml_url}): #{e.message}. The Collection likely has no Items."
      return
    end

    c = Collection.find collection_id

    unless c
      @logger.error "Collection with ID #{collection_id} could not be found."
      raise JobFailedError
    end

    item_data = Nokogiri::XML xml_file

    unless item_data.is_a? Nokogiri::XML::Document and item_data.errors.empty?
      @logger.error 'XML file downloaded but could not be parsed by Nokogiri'
      raise JobFailedError
    end

    xml_file.close
    xml_file.unlink if xml_file.is_a? Tempfile

    items = item_data.css(item_node_name)

    unless c.items.count == 0
      @logger.info "Collection #{c.slug} already has #{c.items.count} items, so no action taken. It should be emptied if you want to re-add Items."
      return true
    end

    item_count = items.length

    @logger.info "Starting import of #{c.display_title} with #{item_count} Items to add"

    items.each do |i|

      hash = Hash.from_xml(i.to_s)
      item_hash = hash['item']
      item_hash.delete('collection')
      item_hash.delete('dc_identifier_label')

      other_collections = item_hash.delete('other_collection')

      item = Item.new(item_hash)
      item.collection = c

      if other_collections
        other_collections.each do |oc|
          other_collection = Collection.find_by_slug(oc)
          if other_collection
            item.other_collections << other_collection.id
          else
            @logger.error "No Collection with slug #{oc} found to add to other_collection array for item #{item.record_id}."
          end
        end
      end

      tries = 3
      begin
        item.save(validate: false)
      rescue => e
        tries -= 1
        if tries > 0
          retry
        else
          @logger.error "Item #{item.record_id} could not be saved: #{e.message}"
        end
      end

      nil

    end

    tries = 3
    begin
      Sunspot.commit_if_dirty
    rescue => e
      tries -= 1
      if tries > 0
        retry
      else
        @logger.error "Sunspot commit failed three times for Collection #{c.display_title} : #{e.message}"
      end
    end

    @logger.info 'Finished importing ' + c.display_title
    @logger.info "XML contained #{item_count} records and Collection now has #{c.items.count} items."

  end

end