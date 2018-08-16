# create Holding Inst entity
class AddHoldingInstitution < ActiveRecord::Migration
  def change
    create_table :holding_institutions do |t|
      t.references :repository, index: true
      t.string :display_name
      t.text :short_description
      t.text :description
      t.string :image
      t.string :homepage_url
      t.string :coordinates
      t.text :strengths
      t.text :contact_information
      t.string :type
      t.boolean :galileo_member
      t.string :contact_name
      t.string :contact_email
      t.string :harvest_strategy
      t.string :oai_url
      t.text :ignored_collections
      t.datetime :last_harvested_at
      t.text :analytics_emails, array: true, default: []
      t.text :subgranting
      t.text :grant_partnerships
    end
    create_join_table :holding_institutions, :collections
  end
end