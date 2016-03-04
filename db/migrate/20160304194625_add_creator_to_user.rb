class AddCreatorToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.references :creator, index: true
    end
  end
end
