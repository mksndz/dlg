class AddMissingDcFieldsToCollection < ActiveRecord::Migration
  def change

    change_table :collections do |t|

      # add missing DC fields
      t.text :dc_creator,  array: true, null: false, default: []
      t.text :dc_language, array: true, null: false, default: []
      t.text :dc_relation, array: true, null: false, default: []

    end

  end
end
