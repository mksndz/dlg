class Item < ActiveRecord::Base
  include SolrIndexing
  include Slugged

  belongs_to :collection
  has_one :repository, through: :collection

  def title
    dc_title.first
  end

  def to_xml(options = {})
    default_options = {
        skip_types: true,
        dasherize: false,
        # fields to not include
        except: [
          :collection_id,
          :created_at,
          :updated_at
        ],
        include: {
            collection: {
                only: [
                    :slug
                ]
            }
        }
    }
    super(options.merge!(default_options))
  end

end
