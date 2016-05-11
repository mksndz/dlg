class AddItemCount < ActiveRecord::Migration

  def change

    change_table :collections do |t|
      t.integer :items_count, default: 0
    end

    Collection.reset_column_information

    Collection.all.each do |c|
      Collection.reset_counters(c.id, :items)
    end

  end

end
