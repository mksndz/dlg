# handle conversion of hash fields to format appropriate for #create
class ItemXmlHashProcessor

  def initialize(hash:, results_service:)
    @hash = hash
    @results_service = results_service
  end

  def record_id
    @hash.fetch 'record_id', 'Record ID not set'
  end

  def converted_hash(fields)
    fields.each do |f|
      begin
        send(f) if @hash.key? f
      rescue StandardError => e
        @results_service.error record_id, e.message
      end
    end
    @hash
  end

  def id
    val = @hash.delete('id')
    @hash['item_id'] = val
  end

  def portals
    val = @hash.delete('portals')
    @hash['portal_ids'] = Portal.where(code: val.map(&:values).flatten).pluck(:id)
  end

  def collection
    val = @hash.delete('collection')
    @hash['collection_id'] = Collection.find_by!(record_id: val.values.first).id
  end

  def other_colls
    val = @hash.delete('other_colls')
    @hash['other_collection_ids'] = Collection.where(record_id: val.map(&:values).flatten).pluck(:id)
  end

  def dcterms_provenance
    val = @hash.delete('dcterms_provenance')
    @hash['holding_institution_ids'] = HoldingInstitution.where(authorized_name: val).pluck(:id)
  end
end