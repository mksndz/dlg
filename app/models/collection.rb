class Collection < ActiveRecord::Base

  has_many :items, dependent: :destroy, counter_cache: true
  has_many :public_items, -> { where public: true }, class_name: 'Item'
  has_many :dpla_items, -> { where dpla: true }, class_name: 'Item'
  belongs_to :repository

  validates_presence_of :slug, :display_title

  searchable do

    string :slug

    # set empty proxy id field so sunspot knows about it
    # value is set prior to save
    # see monkeypatch @ config/initializers/sunspot_indexer_id.rb
    string :sunspot_id do
      ''
    end

    string :in_repository do
      self.repository.title
    end

    boolean :in_georgia
    boolean :public

    text :display_title
    text :teaser
    text :short_description

    text :dc_title
    text :dc_format
    text :dc_publisher
    text :dc_identifier
    text :dc_rights
    text :dc_contributor
    text :dc_coverage_t
    text :dc_coverage_s
    text :dc_date
    text :dc_source
    text :dc_subject
    text :dc_type
    text :dc_description

  end

end
