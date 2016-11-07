class LegacyImporter

  def self.create_repository(xml_node)

    slug = xml_node.css('slug').inner_text

    repository = Repository.new

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
    repository.teaser             = xml_node.css('teaser').inner_text == 'yes'

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
    collection_attributes.delete('teaser') # todo remove teaser when brad removes it from xml

    collection.assign_attributes(collection_attributes)

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

    collection.color = "##{color}"

    # set repository unless already set
    if collection.repository
      collection.save(validate: false)
    else
      repo = Repository.find_by_slug repository['slug']
      if repo
        collection.repository = repo
        collection.save(validate: false)
      else
        logger.error "Needed repo but collection metadata for #{collection.slug} contains unknown repo slug #{repository['slug']}."
        logger.error 'Collection not saved.'
      end
    end

    if collection.errors.present?
      logger.error 'Problem saving Collection. Check errors.'
    end

    collection

  end

end