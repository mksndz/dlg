# services related to parsing ingested XML and creating hashes for creating
# BatchItems
class ItemXmlService

  def initialize(xml:, results_service:, hash_processor:)
    @xml = xml
    @results_service = results_service
    @hash_processor = hash_processor
  end

  # Return hashes prepared for use in a #create call
  def hashes
    convert raw_hashes
  end

  private

  # Convert each hash in raw_hashes to a prepared hash
  # @param raw_hashes [Array] all the hashes from the parsed XML
  def convert(raw_hashes)
    raw_hashes.map(&method(:prepare))
  end

  # Generate raw hash values from XML
  def raw_hashes
    Nokogiri::XML::Reader(@xml).map do |node|
      next unless
        node.name == 'item' &&
        node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

      Hash.from_xml(node.outer_xml)['item']
    end.reject(&:nil?)
  end

  # Use the hash_processor to do the dirty work of converting various hash
  # elements
  # @param hash [Hash] hash to be worked on
  def prepare(hash)
    @hash_processor.new(hash).converted_hash
  rescue StandardError => e
    # rescues any errors thrown by the hash processor, typically AR:NotFound
    @results_service.error e.message
  end

end