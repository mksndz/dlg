# services related to parsing ingested XML and creating hashes for creating
# BatchItems
class ItemXmlService
  attr_accessor :xml

  def hashes
    prepare raw_hashes
  end

  def prepare(raw_hashes)
    raw_hashes.map do |h|
      stuff h
    end
  end

  def raw_hashes
    Nokogiri::XML::Reader(@xml).map do |node|
      next unless
        node.name == 'item' &&
        node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

      Hash.from_xml(node.outer_xml)['item']
    end.reject(&:nil?)
  end

  def stuff(hash)
    # reconfigure relations, set item_id if present
    reconfigure(
      hash,
      %w[portals collection other_colls id holding_institution]
    )
  end

  def reconfigure(hash, fields)
    fields.each do |field|
      transpose hash, field
    end
  end

  def transpose(hash, field)
    Transposer.send(field, hash)
  end

  # handle conversion of hash fields to format appropriate for #create
  class Transposer
    def self.id(hash)
      val = hash.delete('id')
      hash['item_id'] = val
    end

    def self.portals(hash)
      val = hash.delete('portals')
      hash['portal_ids'] = Portal.where(code: val.map(&:values)).pluck(:id)
    end

    def self.collection(hash)
      val = hash.delete('collection')
      hash['collection_id'] = Collection.find_by(record_id: val.value).id
    end
  end
end