class AddTimestamps < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.timestamps
    end
    change_table :holding_institutions do |t|
      t.timestamps
    end
  end
end
