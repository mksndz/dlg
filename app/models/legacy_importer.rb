class LegacyImporter

  THUMBNAIL_ROOT = 'http://dlg.galileo.usg.edu/do-th:'

  def self.get_value(xml, field)
    xml.css(field).inner_text.encode('UTF-8', invalid: :replace, undef: :replace)
        # .gsub('&quot;',"'")
        # .gsub('&apos;',"'")
        # .gsub("\n",'')
  end

  def self.create_repository(xml_node)

    slug = get_value xml_node, 'slug'

    repository = Repository.new

    repository.slug               = slug
    repository.title              = get_value xml_node, 'title'
    repository.short_description  = get_value xml_node, 'short_description'
    repository.description        = get_value xml_node, 'description'
    repository.strengths          = get_value xml_node, 'strengths'
    repository.address            = get_value xml_node, 'address'
    repository.coordinates        = get_value xml_node, 'coordinates'
    repository.directions_url     = get_value xml_node, 'directions_url'
    repository.homepage_url       = get_value xml_node, 'homepage_url'
    repository.in_georgia         = get_value(xml_node, 'in_georgia') == 'true'
    repository.public             = get_value(xml_node, 'public') == 'true'
    repository.color              = "##{get_value xml_node, 'color'}"
    repository.teaser             = get_value(xml_node, 'teaser') == 'true'

    repository.thumbnail_url      = "#{THUMBNAIL_ROOT}#{slug}"

    portals = xml_node.css('portal')

    if portals
      set_portals repository, portals
    end

    repository.save(validate: false)
    repository

  end

  def self.create_collection(xml_node)

    logger = Logger.new('./log/repo_and_coll_import.log')

    collection_attributes = Hash.from_xml xml_node.to_s

    collection_attributes = collection_attributes['coll']

    collection = Collection.find_by_slug collection_attributes['slug']
    collection ||= Collection.new

    # extract attributes for special treatment
    repository = collection_attributes.delete('repository')
    time_periods = collection_attributes.delete('time_period')
    topics = collection_attributes.delete('topic')
    other_repositories = collection_attributes.delete('other_repository')
    color = collection_attributes.delete('color')
    local = collection_attributes.delete('local')
    portals = collection_attributes.delete('portal')

    # ensure a display title is set
    unless collection_attributes['display_title']
      collection_attributes['display_title'] = collection_attributes['dcterms_title'].first
    end

    collection.assign_attributes(collection_attributes)

    if portals
      set_portals collection, xml_node.css('portal')
    end

    if time_periods
      time_periods.each do |xml_tp|
        tp_added = false
        xml_tp.gsub!('Millenium','Millennium')
        TimePeriod.all.each do |tp|
          if xml_tp.index(tp.name)
            collection.time_periods << tp
            tp_added = true
          end
        end
        logger.error "TimePeriod from XML not added: #{xml_tp}" unless tp_added
      end
    end

    if topics
      topics.each do |s|
        subj = Subject.find_by_name s
        if subj
          collection.subjects << subj
        else
          logger.error "Subject could not be added: #{s}"
        end
      end
    end


    if other_repositories
      other_repositories.each do |r|
        other_repository = Repository.find_by_slug(r)
        if other_repository
          collection.other_repositories << other_repository.id
        else
          logger.error "No Repository with slug #{r} found to add to other_repositories array for Collection #{collection.slug}."
        end
      end
    end

    collection.color = "##{color}" if color && !color.empty?

    # set repository unless already set
    if collection.repository
      collection.thumbnail_url = "#{THUMBNAIL_ROOT}#{collection.repository.slug}_#{collection.slug}"
      collection.save(validate: false)
    else

      if repository and repository.has_key? 'slug'
        repo = Repository.find_by_slug repository['slug']

        if repo
          collection.repository = repo
          collection.thumbnail_url = "#{THUMBNAIL_ROOT}#{repo.slug}_#{collection.slug}"
          collection.save(validate: false)
        else
          logger.error "Needed repo but collection metadata for #{collection.slug} contains no or an unknown repo slug (#{repository['slug']})."
          logger.error 'Collection not saved.'
        end

      else
        logger.error "No Repository provided for #{collection.slug}"
      end

    end

    if collection.errors.present?
      logger.error 'Problem saving Collection. Check errors.'
    end

    collection

  end

  def self.set_portals(entity, portals_node)

    portals_hash = Hash.from_xml(portals_node.to_s)
    portals = portals_hash['portal']['code']

    if portals.respond_to? :each

      portals.each do |c|

        portal = Portal.find_by_code c

        entity.portals << portal if portal

      end

    else

      portal = Portal.find_by_code portals
      entity.portals = [portal] if portal

    end

  end

end