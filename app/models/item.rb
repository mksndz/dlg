class Item < ActiveRecord::Base
  include ItemIndexing
  include Slugged

  belongs_to :collection
  has_one :repository, through: :collection

  def title
    dc_title.first
  end

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
