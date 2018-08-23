class ChangeOaiUrlFieldToArray < ActiveRecord::Migration
  def change
    change_table :holding_institutions do |t|
      t.remove :oai_url
      t.text :oai_url, array: true, default: []
    end
  end
end
