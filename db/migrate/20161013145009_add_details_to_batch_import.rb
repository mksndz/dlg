class AddDetailsToBatchImport < ActiveRecord::Migration
  def change
    change_table :batch_imports do |t|
      t.json :results, default: {}
      t.boolean :validations
    end
  end
end
