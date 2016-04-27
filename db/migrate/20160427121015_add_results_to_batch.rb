class AddResultsToBatch < ActiveRecord::Migration
  def change
    change_table :batches do |t|
      t.column :commit_results, :json, default: {}, null: false
    end
  end
end
