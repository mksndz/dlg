class MakeHItoRepoM2M < ActiveRecord::Migration
  def change
    change_table :holding_institutions do |t|
      t.remove :repository_id
    end
    create_join_table :holding_institutions, :repositories
  end
end
