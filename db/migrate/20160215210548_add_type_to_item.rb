class AddTypeToItem < ActiveRecord::Migration
  def change

    change_table :items do |t|

      t.string :type

    end

  end
end
