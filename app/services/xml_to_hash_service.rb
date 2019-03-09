# convert a hypothetical JSONL file to hashes
#class JsonlToHashService; end

# convert actual XML files to hashes
class XmlToHashService

  # Generate raw hash values from XML
  def self.hashes_from(xml)
    target_node = 'item'
    Nokogiri::XML::Reader(xml).map do |node|
      next unless
        node.name == target_node &&
        node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

      Hash.from_xml(node.outer_xml)[target_node]
    end.reject(&:nil?)
  end

end