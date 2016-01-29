class AddMetaEntities < ActiveRecord::Migration
  def change

    # Add Repositories
    create_table :repositories do |t|

      # slug
      t.string  :slug, null: false, uniqueness: true
      t.index   :slug, unique: true

      # dlg specific metadata
      t.boolean :public,      null: false, default: false
      t.boolean :in_georgia,  null: false, default: true
      t.string :title,        null: false
      t.string :color
      t.string :homepage_url
      t.string :directions_url
      t.text :teaser
      t.text :short_description
      t.text :description
      t.text :address
      t.text :strengths
      t.text :contact

      t.timestamps null: false

    end

    # Add Collections
    create_table :collections do |t|

      # slug
      t.string  :slug, null: false, uniqueness: true
      t.index   :slug, unique: true

      # relations
      t.references :repository, index: true, foreign_key: true

      # dlg specific metadata
      t.boolean :dpla,          null: false, default: false, index: true
      t.boolean :public,        null: false, default: false, index: true
      t.boolean :in_georgia,    null: false, default: true
      t.boolean :remote,        null: false, default: false
      t.text    :display_title, null: false
      t.text    :short_description
      t.text    :teaser
      t.string  :color

      # 'other repositories' for the rare cases where a collection is
      # in >1 repository
      t.integer :other_repositories, array: true, null: false, default: []

      # dublin core fields
      t.text :dc_title,       array: true, null: false, default: []
      t.text :dc_format,      array: true, null: false, default: []
      t.text :dc_publisher,   array: true, null: false, default: []
      t.text :dc_identifier,  array: true, null: false, default: []
      t.text :dc_rights,      array: true, null: false, default: []
      t.text :dc_contributor, array: true, null: false, default: []
      t.text :dc_coverage_t,  array: true, null: false, default: []
      t.text :dc_coverage_s,  array: true, null: false, default: []
      t.text :dc_date,        array: true, null: false, default: []
      t.text :dc_source,      array: true, null: false, default: []
      t.text :dc_subject,     array: true, null: false, default: []
      t.text :dc_type,        array: true, null: false, default: []
      t.text :dc_description, array: true, null: false, default: []

      # daterange
      t.daterange :date_range

      t.timestamps null: false
    end

    # Add Items
    create_table :items do |t|

      # slug
      t.string  :slug, null: false, uniqueness: true
      t.index   :slug, unique: true

      # relations
      t.references :collection, index: true, foreign_key: true

      # dlg specific metadata
      t.boolean :dpla,        null: false, default: false, index: true
      t.boolean :public,      null: false, default: false, index: true
      t.boolean :in_georgia,  null: false, default: true

      # 'other collections' for the rare cases where an item is in >1 collection
      t.integer :other_collections, array: true, null: false, default: []

      # dublin core fields
      t.text :dc_title,       array: true, null: false, default: []
      t.text :dc_format,      array: true, null: false, default: []
      t.text :dc_publisher,   array: true, null: false, default: []
      t.text :dc_identifier,  array: true, null: false, default: []
      t.text :dc_rights,      array: true, null: false, default: []
      t.text :dc_contributor, array: true, null: false, default: []
      t.text :dc_coverage_t,  array: true, null: false, default: []
      t.text :dc_coverage_s,  array: true, null: false, default: []
      t.text :dc_date,        array: true, null: false, default: []
      t.text :dc_source,      array: true, null: false, default: []
      t.text :dc_subject,     array: true, null: false, default: []
      t.text :dc_type,        array: true, null: false, default: []
      t.text :dc_description, array: true, null: false, default: []

      # timestamps
      t.timestamps null: false

    end

  end
end
