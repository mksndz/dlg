class Collection < ActiveRecord::Base
  include Slugged
  # include SolrIndexing

  has_many :items, dependent: :destroy
  has_many :public_items, -> { where public: true }, class_name: 'Item'
  has_many :dpla_items, -> { where dpla: true }, class_name: 'Item'
  belongs_to :repository
  has_and_belongs_to_many :subjects
  has_and_belongs_to_many :users

  validates_presence_of :display_title
  validates_uniqueness_of :slug, scope: :repository_id

  def title
    dcterms_title.first
  end

  # allow Items to delegate collection_title
  alias_method :collection_title, :title

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

  def self.index_query(params)
    options = {}
    fields = %w(repository_id public).freeze
    if params.present?
      fields.each do |f|
        options[f] = params[f] if params[f] && !params[f].empty?
      end
    end
    options.present? ? where(options) : all
  end

end

