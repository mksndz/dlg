class Collection < ActiveRecord::Base
  include Slugged
  include SolrIndexing

  has_many :items, dependent: :destroy
  has_many :public_items, -> { where public: true }, class_name: 'Item'
  has_many :dpla_items, -> { where dpla: true }, class_name: 'Item'
  belongs_to :repository
  has_and_belongs_to_many :subjects
  # accepts_nested_attributes_for :subjects

  validates_presence_of :display_title

  def title
    dc_title.first
  end

  def to_xml(options = {})
    default_options = {
        dasherize: false,
        # fields to not include
        except: [
            :repository_id,
            :created_at,
            :updated_at,
            :other_collections
        ]
    }

    if options[:show_repository]
      default_options[:include] = [ repository: { only: [ :slug ] } ]
    end

    super(options.merge!(default_options))
  end

end
