# add timestamps to Feature model
class AddTimestampsToFeature < ActiveRecord::Migration
  def change
    change_table :features, &:timestamps
  end
end
