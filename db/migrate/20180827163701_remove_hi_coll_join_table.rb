class RemoveHiCollJoinTable < ActiveRecord::Migration
  def change
    drop_join_table :holding_institutions, :collections
  end
end
