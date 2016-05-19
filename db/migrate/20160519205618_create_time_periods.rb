class CreateTimePeriods < ActiveRecord::Migration
  def change
    create_table :time_periods do |t|
      t.string :name
      t.datetime :start
      t.datetime :end

      t.timestamps null: false
    end

    create_join_table :time_periods, :collections do |t|
      t.index [:collection_id, :time_period_id], name: :idx_col_time_per_on_coll_and_time_per
      t.index [:time_period_id, :collection_id], name: :idx_col_time_per_on_time_per_and_coll
    end
  end
end
