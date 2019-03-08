# services related to parsing ingested XML and creating hashes for creating
# BatchItems
class ItemXmlService

  def initialize(xml:, results_service:, hash_processor:)
    @xml = xml
    @results_service = results_service
    @hash_processor = hash_processor
  end

  def hashes
    convert raw_hashes
  end

  def convert(raw_hashes)
    raw_hashes.map(&method(:prepare))
  end

  def raw_hashes
    Nokogiri::XML::Reader(@xml).map do |node|
      next unless
        node.name == 'item' &&
        node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

      Hash.from_xml(node.outer_xml)['item']
    end.reject(&:nil?)
  end

  def prepare(hash)
    fields = %w[portals collection other_colls id dcterms_provenance]
    @hash_processor.new(hash).converted_hash(fields)
  end

end