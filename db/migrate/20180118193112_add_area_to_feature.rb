# adds an 'area' column to Feature to specify where the feature should be located
class AddAreaToFeature < ActiveRecord::Migration
  def change
    add_column :features, :area, :string
  end
end
