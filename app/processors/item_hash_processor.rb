# handle conversion of hash fields to format appropriate for #create
class ItemHashProcessor

  FIELDS = %w[id portals collection other_colls dcterms_provenance].freeze

  def initialize(hash)
    @hash = hash
  end

  def process
    FIELDS.each do |field|
      send(field) if @hash.key? field
    end
    @hash
  end

  private

  def id
    @hash['item_id'] = @hash.delete('id')
  end

  def portals
    portals = @hash.delete('portals')
    @hash['portal_ids'] = portals.map do |portal_info|
      Portal.find_by!(portal_info).id
    end
  end

  def collection
    val = @hash.delete('collection')
    @hash['collection_id'] = Collection.find_by!(record_id: val.values.first).id
  end

  def other_colls
    other_collections = @hash.delete('other_colls')
    @hash['other_collections'] = other_collections.map do |other|
      Collection.find_by!(other).id
    end
  end

  def dcterms_provenance
    provenances = @hash.delete('dcterms_provenance')
    @hash['holding_institution_ids'] = provenances.map do |provenance|
      HoldingInstitution.find_by!(authorized_name: provenance).id
    end
  end
end