class AddCoordinatesToRepository < ActiveRecord::Migration
  def change
    change_table :repositories do |t|
      t.string :coordinates
    end
  end
end
