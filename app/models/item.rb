class Item < AbstractItem
  include ItemIndexing

  def to_xml(options = {})
    default_options = {
        dasherize: false,
        # fields to not include
        except: [
          :batch_id,
          :collection_id,
          :created_at,
          :updated_at,
          :other_collections
        ],
        include: [
            collection: { only: [ :slug ] },
            repository: { only: [ :slug ] }
        ]
    }
    super(options.merge!(default_options))
  end

end
