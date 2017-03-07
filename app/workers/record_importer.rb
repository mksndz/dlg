class RecordImporter

  @queue = :xml

  def self.perform(batch_import_id)

    @batch_import = BatchImport.find(batch_import_id)

    @added = 0
    @failed = 0
    @batch = @batch_import.batch
    @validate = @batch_import.validations?
    @added = []
    @updated = []
    @failed = []

    case @batch_import.format

        when 'file' || 'text'

          xml_data = Nokogiri::XML @batch_import.xml

          unless xml_data.is_a? Nokogiri::XML::Document and xml_data.errors.empty?
            total_failure 'XML could not be parsed, probably due to invalid XML format.'
            return
          end

          records = xml_data.css('item')
          n = records.length

          unless n > 0
            total_failure 'No records could be extracted from the XML'
            return
          end

          records.each_with_index do |r, i|
            record = Hash.from_xml(r.to_s)
            create_or_update_record i + 1, record['item']
          end
        
        when 'search query'

          @batch_import.item_ids.each_with_index do |id, index|

            begin
              i = Item.find id
              batch_item = i.to_batch_item
              batch_item.batch = @batch
              batch_item.save(validate: false)
              add_updated i.slug, batch_item, i.id
            rescue ActiveRecord::RecordNotFound => ar_e
              add_failed index, "Record with ID #{id} could not be found to add to Batch."
            rescue StandardError => e
              add_failed index, "Item #{i.record_id} could not be added to Batch: #{e}"
            end

          end
        
        else

          total_failure 'No format specified'

    end

    @batch_import.results = {
        added: @added,
        updated: @updated,
        failed: @failed
    }

    @batch_import.completed_at = Time.now

    save_batch_import

  end

  def self.create_or_update_record(num, record_data)

    collection_info = record_data.delete('collection')
    collection_slug = collection_info['slug']

    unless collection_slug
      add_failed num, "Collection slug for record #{record_data['slug']} could not be extracted from XML."
      return
    end

    collection = Collection.find_by_slug collection_slug

    unless collection
      add_failed num, "Collection for record #{record_data['slug']} could not be found using slug: #{collection_slug}."
      return
    end

    # existing_item = Item.find_by_slug record_data['slug']

    # look for existing item based on unique attributes
    item_lookup = Item.where(slug: record_data['slug'], collection: collection)

    if item_lookup.length > 1
      add_failed num, "More than one existing Item match for #{record_data['slug']} in Collection #{collection_slug}. This should never happen!"
    end

    begin

      if item_lookup.any?
        action = :update
        create_update_record(item_lookup.first, record_data)
      else
        action = :add
        create_new_record(record_data)
      end

    rescue StandardError => e
      add_failed num, "Generating BatchItem failed for record #{record_data['slug']}. Error: #{e} "
      return
    end

    @record.batch = @batch
    @record.collection = collection

    begin

      if @record.save(validates: @validate)

        if action == :update
          add_updated(@record.slug, @record.id, @record.item_id)
        else
          add_added(@record.slug, @record.id)
        end

      else
        add_failed(num, @record.errors) # todo how best to write these errors to hash? could contain multiple validation messages
      end

    rescue ActiveRecord::RecordInvalid => e
      add_failed(num, "XML contains invalid record #{record_data['slug']}. Validation message: #{e}")

    rescue StandardError => e
      add_failed(num, "Could not save record #{record_data['slug']}. Error: #{e}")

    end

  end

  def self.create_update_record(existing_item, record_data)
    create_new_record(prepared_params(record_data))
    @record.item = existing_item
  end

  def self.create_new_record(record_data)
    @record = BatchItem.new prepared_params(record_data)
    @record.batch_import = @batch_import
  end

  # reject any values the db is not prepared for...
  def self.prepared_params(record_data)
    record_data.reject do |k,v|
      if BatchItem.column_names.exclude?(k)
        # @logger.warn "Param from XML discarded: #{k}" todo fix this (set logger)
        k
        true
      end
    end
  end

  def self.add_failed(num, message)
    @failed << {
        number: num,
        message: message
    }
  end

  def self.add_added(slug, batch_item_id)
    @added << {
        batch_item_id: batch_item_id,
        slug: slug
    }
  end

  def self.add_updated(slug, batch_item_id, item_id)
    @updated << {
        batch_item_id: batch_item_id,
        item_id: item_id,
        slug: slug
    }
  end

  def self.total_failure(msg)
    @batch_import.results = {
        added: @added,
        updated: @updated,
        failed: [{number: 0, message: msg}]
    }
    save_batch_import
  end

  def self.save_batch_import
    raise JobFailedError("BatchImport could not be updated: #{@batch_import.errors.inspect}") unless @batch_import.save
  end

end