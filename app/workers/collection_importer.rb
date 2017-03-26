class CollectionImporter

  @queue = :items
  @logger = Logger.new('./log/item_import.log')

  def self.perform(collection_id, items_xml_url)

    item_node_name = 'item'.freeze

    begin
      c = Collection.find collection_id
    rescue ActiveRecord::RecordNotFound
      @logger.error "Collection with ID #{collection_id} could not be found."
      raise JobFailedError
    end

    begin
      xml_file = open items_xml_url
    rescue StandardError => e
      @logger.info "Could not get XML from provided URL(#{items_xml_url}): #{e.message}. The Collection likely has no Items."
      return
    end

#     xml_test = <<XML
# <?xml version="1.0" encoding="UTF-8"?>
# <item>
#   <dpla type="boolean">true</dpla>
#   <public type="boolean">true</public>
#   <dc_format type="array">
#     <dc_format>application/pdf</dc_format>
#   </dc_format>
#   <dc_right type="array"/>
#   <dc_date type="array">
#     <dc_date>1912</dc_date>
#   </dc_date>
#   <dc_relation type="array"/>
#   <slug>ahc0091-001-001</slug>
#   <dcterms_is_part_of type="array"/>
#   <dcterms_contributor type="array"/>
#   <dcterms_creator type="array">
#     <dcterms_creator>Frank, Leo, 1884-1915</dcterms_creator>
#   </dcterms_creator>
#   <dcterms_description type="array"/>
#   <dcterms_extent type="array"/>
#   <dcterms_medium type="array">
#     <dcterms_medium>Letters (correspondence)</dcterms_medium>
#   </dcterms_medium>
#   <dcterms_identifier type="array">
#     <dcterms_identifier>http://dlg.galileo.usg.edu/ahc/leofrank/do:ahc0091-001-001</dcterms_identifier>
#   </dcterms_identifier>
#   <dcterms_language type="array"/>
#   <dcterms_spatial type="array">
#     <dcterms_spatial>United States, Georgia, Fulton County, Atlanta, 33.7489954, -84.3879824</dcterms_spatial>
#   </dcterms_spatial>
#   <dcterms_publisher type="array">
#     <dcterms_publisher>Box 1 Folder 1, Leo Frank papers, MSS 91, Kenan Research Center at the Atlanta History Center.</dcterms_publisher>
#   </dcterms_publisher>
#   <dcterms_rights_holder type="array"/>
#   <dcterms_subject type="array">
#     <dcterms_subject>Jews--Georgia--Atlanta
# </dcterms_subject>
#     <dcterms_subject>Frank, Leo, 1884-1915--Trials, litigation, etc.</dcterms_subject>
#   </dcterms_subject>
#   <dcterms_temporal type="array"/>
#   <dcterms_title type="array">
#     <dcterms_title>Letters of sympathy and support to Leo Frank, 1912</dcterms_title>
#   </dcterms_title>
#   <dcterms_type type="array">
#     <dcterms_type>Text</dcterms_type>
#   </dcterms_type>
#   <dcterms_is_shown_at type="array">
#     <dcterms_is_shown_at>http://dlg.galileo.usg.edu/id:geh_0091_ahc0091-001-001</dcterms_is_shown_at>
#   </dcterms_is_shown_at>
#   <dcterms_provenance type="array">
#     <dcterms_provenance>Atlanta History Center</dcterms_provenance>
#   </dcterms_provenance>
#   <dlg_local_right type="array"/>
#   <dcterms_bibliographic_citation type="array">
#     <dcterms_bibliographic_citation>Cite as: Leo Frank papers, MSS 91, Kenan Research Center at the Atlanta History Center.</dcterms_bibliographic_citation>
#   </dcterms_bibliographic_citation>
#   <local type="boolean">true</local>
#   <dlg_subject_personal type="array"/>
#   <other_colls type="array">
#     <other_coll>
#       <record_id>gaarchives_adhoc</record_id>
#     </other_coll>
#     <other_coll>
#       <record_id>gaarchives_cac</record_id>
#     </other_coll>
#   </other_colls>
#   <collection>
#     <record_id>geh_0091</record_id>
#   </collection>
#   <portals type="array">
#     <portal>
#       <code>georgia</code>
#       <code>other</code>
#     </portal>
#   </portals>
# </item>
# XML

    item_data = Nokogiri::XML xml_file
    # item_data = Nokogiri::XML xml_test

    unless item_data.is_a? Nokogiri::XML::Document and item_data.errors.empty?
      @logger.error 'XML file downloaded but could not be parsed by Nokogiri'
      raise JobFailedError
    end

    xml_file.close
    xml_file.unlink if xml_file.is_a? Tempfile

    items = item_data.css(item_node_name)

    unless c.items.count == 0
      @logger.info "Collection #{c.slug} already has #{c.items.count} items, so no action taken. It should be emptied if you want to re-add Items."
      return true
    end

    item_count = items.length

    @logger.info "Starting import of #{c.display_title} with #{item_count} Items to add"

    items.each do |i|

      hash = Hash.from_xml(i.to_s)
      item_hash = hash['item']
      item_hash.delete('dc_identifier_label')
      portals = item_hash.delete('portals')
      other_collections = item_hash.delete('other_colls')
      collection = item_hash.delete('collection')

      item = Item.new(item_hash)
      item.collection = c

      # set portals value
      LegacyImporter.set_portals(item, portals) if portals

      if other_collections
        other_collections.each do |oc|
          other_collection = Collection.find_by_record_id(oc['record_id'])
          if other_collection
            item.other_collections << other_collection.id
          else
            @logger.error "No Collection with slug #{oc} found to add to other_collection array for item #{item.record_id}."
          end
        end
      end

      tries = 3
      begin
        item.save(validate: false)
      rescue => e
        tries -= 1
        if tries > 0
          retry
        else
          @logger.error "Item #{item.record_id} could not be saved: #{e.message}"
        end
      end

      nil

    end

    tries = 3
    begin
      Sunspot.commit_if_dirty
    rescue => e
      tries -= 1
      if tries > 0
        retry
      else
        @logger.error "Sunspot commit failed three times for Collection #{c.display_title} : #{e.message}"
      end
    end

    @logger.info 'Finished importing ' + c.display_title
    @logger.info "XML contained #{item_count} records and Collection now has #{c.items.count} items."

  end

end