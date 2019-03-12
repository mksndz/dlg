# job to process source records into batch_items
include XmlImportHelper
class RecordImporter
  MAX_BATCH_SIZE = 8_000
  @queue = :xml
  # @logger = Logger.new('./log/xml_import.log')
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  def self.batch_too_large?
    item_nodes = @batch_import.xml.match(/<item>/)
    return unless item_nodes.present?

    item_nodes_count = item_nodes.length
    batch_size = @batch_import.batch.batch_items_count
    new_size = item_nodes_count + batch_size
    if new_size > MAX_BATCH_SIZE
      raise(
        JobTooBigError,
        "This XML Ingest would result in a Batch over the limit of #{MAX_BATCH_SIZE} batch items."
      )
    end
  end

  def self.perform(batch_import_id)
    t1 = Time.now
    @batch_import = BatchImport.find(batch_import_id)

    @added = 0
    @failed = 0
    @batch = @batch_import.batch
    @validate = @batch_import.validations?
    @added = []
    @updated = []
    @failed = []

    @records = []

    import_type = @batch_import.format

    case import_type
    when 'file', 'text'
      count = 0
      begin
        batch_too_large?
        Nokogiri::XML::Reader(@batch_import.xml).each do |node|
          next unless
            node.name == 'item' &&
            node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

          count += 1
          record = Hash.from_xml(node.outer_xml)['item']
          unless record
            add_failed(count, 'Item node could not be converted to hash.')
            next
          end
          # unless record.key? 'item'
          #   add_failed(count, 'No Item node could be extracted from XML')
          #   next
          # end

          # MK 3/12/2019
          # Moved this outside fo the XML Reader to hopefully save some memory
          # create_or_update_record count, record['item']
          @records << record
        end
      rescue Nokogiri::XML::SyntaxError => e
        total_failure "Fundamental XML parsing error: #{e.message}"
      rescue JobTooBigError => e
        total_failure e.message
      end

      if @records.any?
        @records.each_with_index do |record, i|
          create_or_update_record i + 1, record
        end
      else
        total_failure 'No records could be extracted from the XML'
      end

    when 'search query'
      @batch_import.item_ids.each_with_index do |id, index|
        begin
          i = Item.find id
          batch_item = i.to_batch_item
          batch_item.batch_import = @batch_import
          batch_item.batch = @batch
          batch_item.portals = i.portals
          batch_item.save(validate: false)
          add_updated i.slug, batch_item.id, i.id
        rescue ActiveRecord::RecordNotFound
          add_failed(index, "Record with ID #{id} could not be found to add to Batch.",)
        rescue StandardError => e
          add_failed(index, "Item #{i.record_id} could not be added to Batch: #{e}")
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
    t2 = Time.now
    notify "BatchImport `#{batch_import_id}` complete in `#{t2 - t1}` seconds. `#{@added.length}` new. `#{@updated.length}` updated and `#{@failed.length}` errors."

  end

  def self.create_or_update_record(num, record_data)
    record_data = XmlImportHelper.prepare_item_hash(record_data)
    collection_info = record_data.delete('collection')
    unless collection_info
      add_failed(num, "No collection node could be extracted for record #{num}.")
      return
    end
    collection_slug = collection_info.key?('slug') ? collection_info['slug'] : nil
    collection_record_id = collection_info.key?('record_id') ? collection_info['record_id'] : nil
    unless collection_slug || collection_record_id
      add_failed num, "Collection slug for record ##{num} could not be extracted from XML."
      return
    end
    collection = nil
    collection = Collection.find_by_slug collection_slug if collection_slug
    collection = Collection.find_by_record_id collection_record_id if collection_record_id
    unless collection
      add_failed num, "Collection for record #{record_data['slug']} could not be found using record id: #{collection_record_id}." if collection_record_id
      add_failed num, "Collection for record #{record_data['slug']} could not be found using slug: #{collection_slug}." if collection_slug
      return
    end
    item_id = record_data.delete('id')
    if @batch_import.match_on_id?
      item_lookup = Item.find item_id
      add_failed num, "Item with database ID #{item_id} not found." unless item_lookup
    else
      # look for existing item based on unique attributes
      item_lookup = Item.find_by(slug: record_data['slug'], collection: collection)
    end
    begin
      if item_lookup
        action = :update
        create_update_record(item_lookup, record_data)
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
      if @record.save!(validate: @validate)
        if action == :update
          add_updated(@record.slug, @record.id, @record.item_id)
        else
          add_added(@record.slug, @record.id)
        end
      else
        add_failed(
          num,
          @record.errors,
          safe_record_slug
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      add_failed(
        num,
        "XML contains invalid record #{record_data['slug']}. Validation message: #{e}",
        safe_record_slug
      )
    rescue StandardError => e
      add_failed(
        num,
        "Could not save record #{record_data['slug']}. Error: #{e}",
        safe_record_slug
      )
    end
  end

  def self.safe_record_slug
    @record.try(:slug) ? @record.slug : 'Slug could not be determined'
  end

  def self.create_update_record(existing_item, record_data)
    create_new_record record_data
    @record.item = existing_item
  end

  def self.create_new_record(record_data)
    portals = record_data.delete('portals')
    other_colls = record_data.delete('other_colls')
    holding_institutions = record_data.delete('dcterms_provenance')
    @record = BatchItem.new prepared_params(record_data)
    set_record_portals(portals) if portals
    set_record_other_colls(other_colls) if other_colls
    set_record_holding_institutions(holding_institutions) if holding_institutions
    @record.batch_import = @batch_import
  end

  # reject any values the db is not prepared for...
  def self.prepared_params(record_data)
    # record_data.reject do |k, _|
    #   BatchItem.column_names.exclude? k
    # end
    prepared_data = {}
    record_data.each do |k, v|
      next unless BatchItem.column_names.include?(k)

      prepared_data[k] = if v.is_a? Array
                           v.map do |val|
                             val.gsub('\\n', "\n").gsub('\\t', "\t").strip if val.is_a? String
                           end
                         else
                           v
                         end
    end
    prepared_data
  end

  def self.add_failed(num, message, slug = nil)
    @failed << {
      number: num,
      slug: slug,
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
    notify "Batch Import `#{@batch_import.id}` failed: #{msg}"
    add_failed 0, msg
    # @batch_import.results = {
    #   added: @added,
    #   updated: @updated,
    #   failed: [{ number: 0, message: msg }]
    # }
    # save_batch_import
  end

  def self.save_batch_import
    raise JobFailedError("BatchImport could not be updated: #{@batch_import.errors.inspect}") unless @batch_import.save
  end

  def self.set_record_portals(portals_info)
    @record.portals = portals_info.map { |portal| Portal.find_by_code portal['code'] }
  rescue StandardError => e
    raise StandardError, 'Portal values could not be set.'
  end

  def self.set_record_other_colls(other_colls_info)
    @record.other_collections = other_colls_info.map do |other_coll|
      Collection.find_by_record_id(other_coll['record_id']).id if other_coll['record_id']
    end
  rescue StandardError => e
    raise StandardError, 'Other Collections values could not be set.'
  end

  def self.set_record_holding_institutions(holding_institution_names)
    holding_institution_names.each do |holding_institution_name|
      holding_institution_object = HoldingInstitution.find_by_authorized_name holding_institution_name
      if holding_institution_object
        @record.holding_institutions << holding_institution_object
      else
        raise(
          StandardError,
          "Could not find Holding Institution for '#{holding_institution_name}'"
        )
      end
    end
  rescue StandardError => e
    raise StandardError, "Problem setting Holding Institution: #{e}."
  end

  def self.notify(msg)
    @slack.ping msg if Rails.env.production?
  end

end