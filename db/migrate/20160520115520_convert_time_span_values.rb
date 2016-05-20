class ConvertTimeSpanValues < ActiveRecord::Migration
  def change
    change_table :time_periods do |t|
      t.remove :start
      t.remove :finish
      t.integer :start
      t.integer :finish
    end
  end
end
