class RecordImporter

  @queue = :xml
  @logger = Logger.new('./log/xml_import.log')

    # config
  PRODUCT = 'batch_item'
  TARGET = 'item'
  PARENT = 'collection'

  def self.perform(batch_import)

    @added = 0
    @failed = 0
    @batch = batch_import.batch
    @validate = false # todo

    xml_data = Nokogiri::XML batch_import.xml

    unless xml_data.is_a? Nokogiri::XML::Document and xml_data.errors.empty?
      @logger.error 'XML file downloaded but could not be parsed by Nokogiri'
      raise JobFailedError
    end

    records = xml_data.css('item')
    n = records.length

    unless n > 0
      @logger.error 'No records could be extracted from the XML'
      raise JobFailedError
    end

    @logger.info "Processing XML file with #{n} records"

    records.each do |r|
      record = Hash.from_xml(r.to_s)
      create_or_update_record record['item']
    end

  end

  def self.create_or_update_record(record_data)

    collection_info = record_data.delete('collection')
    collection_slug = collection_info['slug']

    unless collection_slug
      @logger.error "Collection slug for record #{record_data['slug']} could not be extracted from XML."
      return false
    end

    collection = Collection.find_by_slug collection_slug

    unless collection
      @logger.error "Collection for record #{record_data['slug']} could not be found using slug: #{collection_slug}."
      return false
    end

    existing_item = Item.find_by_slug record_data['slug']

    begin
      if existing_item
        create_update_record(existing_item, record_data)
      else
        create_new_record(record_data)
      end
    rescue StandardError => e
      @logger.error "Generating BatchItem failed for record #{record_data['slug']}. Error: #{e} "
      raise JobFailedError
    end

    @record.batch = @batch
    @record.collection = collection

    begin
      @record.save(validates: @validate)
    rescue ActiveRecord::RecordInvalid => e
      @logger.error "XML contains invalid record #{record_data['slug']}. Validation message: #{e}"
    rescue StandardError => e
      @logger.error "Could not save record #{record_data['slug']}. Error: #{e}"
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

end