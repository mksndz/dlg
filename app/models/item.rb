class Item < ActiveRecord::Base

  belongs_to :collection
  has_one :repository, through: :collection

  searchable do

    string :slug

    # set empty proxy id field so sunspot knows about it
    # value is set prior to save
    # see monkeypatch @ config/initializers/sunspot_indexer_id.rb
    string :sunspot_id do
      ''
    end

    boolean :dpla
    boolean :public

    string :in_collection do
      if self.collection
        self.collection.display_title
      else
        ''
      end
    end

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
