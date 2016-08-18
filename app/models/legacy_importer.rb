class LegacyImporter

  @logger = Logger.new('./log/item_import.log')

  # Import a collection's items (not the collection's metadata)
  # todo rename...populate_collection?
  # @string slug
  # @string xml_url
  def self.collection(collection, xml_url)

    unless collection.is_a? Collection
      @logger.error 'collection is not a Collection'
      return false
    end

    if xml_url.empty?
      @logger.error 'No xml url provided'
      return false
    end

    items_created = 0

    collection_start_time = Time.now

    @logger.info "Importing Items from XML: #{xml_url}"

    xml_file = open(xml_url)

    @data = Nokogiri::HTML(xml_file)

    unless @data.is_a? Nokogiri::HTML::Document
      @logger.error "Could'nt get valid XML from #{data_source}"
      return false
    end

    items = @data.css('item')

    items_to_add = items.length

    @logger.info "XML for #{collection.display_title} has #{items.length} to add"

    item_counter = 0

    items.each do |item|

      item_counter += 1

      hash = Hash.from_xml(item.to_s)

      item_hash = hash['item']

      item_hash.delete('collection')
      item_hash.delete('dc_identifier_label')
      other_collections = item_hash.delete('other_collection')

      i = Item.new(item_hash)
      i.collection = collection

      if other_collections
        other_collections.each do |oc|
          other_collection = Collection.find_by_slug(oc)
          if other_collection
            i.other_collections << other_collection.id
          else
            @logger.error "No Collection with slug #{oc} found to add to other_collection array for item #{i.record_id}."
          end
        end
      end

      begin
        i.save(validate: false)
        @logger.info "#{collection.display_title}: #{item_counter} of #{items_to_add}" if item_counter % 50 == 0
      rescue => e
        @logger.error "Item #{i.record_id} could not be saved: #{e.message}"
      end

      # run GC fdor every 10000 records? maybe this will help :/
      if item_counter % 10000 == 0
        @logger.info 'Cleaning up...'
        GC.start
      end

    end

    Sunspot.commit

    @logger.info "Collection #{collection.title} Items Created: #{items_created}"
    @logger.info "Collection #{collection.title} Items In XML: #{items.length}"

    xml_file.close

    # clean up file XML file from memory, if saved
    if xml_file.is_a? Tempfile
      xml_file.unlink
    end

    collection_finish_time = Time.now

    @logger.info "Importing #{xml_url} took #{collection_finish_time - collection_start_time} seconds!"

  end

  def self.create_or_update_repository(xml_node)

    slug = xml_node.css('slug').inner_text

    repository = Repository.find_by_slug slug
    repository ||= Repository.new

    repository.slug               = slug
    repository.title              = xml_node.css('title').inner_text
    repository.short_description  = xml_node.css('short_description').inner_text
    repository.description        = xml_node.css('description').inner_text
    repository.strengths          = xml_node.css('strengths').inner_text
    repository.address            = xml_node.css('address').inner_text
    repository.coordinates        = xml_node.css('coordinates').inner_text
    repository.directions_url     = xml_node.css('directions_url').inner_text
    repository.homepage_url       = xml_node.css('homepage_url').inner_text
    repository.in_georgia         = xml_node.css('in_georgia').inner_text == 'yes'
    repository.public             = xml_node.css('public').inner_text == 'yes'
    repository.color              = "##{xml_node.css('color').inner_text}"
    repository.teaser             = xml_node.css('teaser').inner_text

    repository.save(validate: false)
    repository

  end

  def self.create_repository_collections(repository, collections_data)

    return 0 unless collections_data

    collections_data.each do |collection_basic_info|
      collection = Collection.find_by_slug collection_basic_info[:slug]
      collection ||= Collection.new
      collection.slug = collection_basic_info[:slug]
      collection.display_title = collection_basic_info[:name]
      collection.repository = repository
      collection.save(validate: false)
    end

    return repository.collections.count

  end

end