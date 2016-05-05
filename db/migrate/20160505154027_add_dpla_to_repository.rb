class AddDplaToRepository < ActiveRecord::Migration
  def change
    change_table :repositories do |t|
      t.boolean :dpla, null: false, default: false, index: true
    end
  end
end
