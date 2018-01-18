# add Feature entity to support Public site homepage
class AddFeature < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :title
      t.string :title_link
      t.string :institution
      t.string :institution_link
      t.string :short_description
      t.string :external_link
      t.boolean :primary
    end
  end
end
