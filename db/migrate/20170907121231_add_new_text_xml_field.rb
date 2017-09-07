# adds a new TEXT type field that will replace the VARCHAR xml field on
# batch_import
class AddNewTextXmlField < ActiveRecord::Migration
  def change
    change_table :batch_imports do |t|
      t.text :user_xml
    end
  end
end
