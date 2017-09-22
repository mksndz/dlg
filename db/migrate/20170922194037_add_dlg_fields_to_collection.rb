class AddDlgFieldsToCollection < ActiveRecord::Migration
  def change
    change_table :collections do |t|
      t.string :partner_homepage_url
      t.text :homepage_text
    end
  end
end
