class DropDcIdentifier < ActiveRecord::Migration
  def change
    change_table :items do |t|
      t.remove :dc_identifier
    end
    change_table :batch_items do |t|
      t.remove :dc_identifier
    end
    change_table :collections do |t|
      t.remove :dc_identifier
    end
  end
end
