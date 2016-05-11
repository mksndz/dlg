class AddCollectionCount < ActiveRecord::Migration
  def change

    change_table :repositories do |t|
      t.integer :collections_count, default: 0
    end

    Repository.reset_column_information

    Repository.all.each do |r|
      Repository.reset_counters(r.id, :collections)
    end

  end

end
