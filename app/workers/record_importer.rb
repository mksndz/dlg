class RecordImporter

  @queue = :xml
  @logger = Logger.new('./log/xml_import.log')

  def self.perform(batch_import, validate = true)

    @batch_import = batch_import
    @added = 0
    @failed = 0
    @batch = @batch_import.batch
    @validate = validate
    @added = []
    @updated = []
    @failed = []

    xml_data = Nokogiri::XML @batch_import.xml

    unless xml_data.is_a? Nokogiri::XML::Document and xml_data.errors.empty?
      @logger.error 'XML could not be parsed by Nokogiri'
      raise JobFailedError
    end

    records = xml_data.css('item')
    n = records.length

    unless n > 0
      @logger.error 'No records could be extracted from the XML'
      raise JobFailedError
    end

    @logger.info "Processing XML file with #{n} records"

    records.each_with_index do |r, i|
      record = Hash.from_xml(r.to_s)
      create_or_update_record i + 1, record['item']
    end

    @logger.info 'XML processing complete.'

    @batch_import.results = {
        added: @added,
        updated: @updated,
        failed: @failed
    }
    @batch_import.added   = @added.length
    @batch_import.updated = @updated.length
    @batch_import.failed  = @failed.length

    @batch_import.save

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

    existing_item = Item.find_by_slug record_data['slug']

    begin

      if existing_item
        action = :update
        create_update_record(existing_item, record_data)
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
  end

  # reject any values the db is not prepared for...
  def self.prepared_params(record_data)
    record_data.reject do |k,v|
      if BatchItem.column_names.exclude?(k)
        @logger.warn "Param from XML discarded: #{k}"
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

end