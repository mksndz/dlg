class Repository < ActiveRecord::Base

  has_many :collections, dependent: :destroy
  has_many :public_collections, -> { where public: true }, class_name: 'Collection'
  has_many :dpla_collections, -> { where dpla: true }, class_name: 'Collection'
  has_many :items, through: :collections

  validates_presence_of :slug, :title
  validates_uniqueness_of :slug

  searchable do

    string :slug

    # set empty proxy id field so sunspot knows about it
    # value is set prior to save
    # see monkeypatch @ config/initializers/sunspot_indexer_id.rb
    string :sunspot_id do
      ''
    end

    string :homepage_url
    string :directions_url

    boolean :in_georgia
    boolean :public

    text :title
    text :description
    text :teaser
    text :short_description
    text :address
    text :strengths
    text :contact

  end

end