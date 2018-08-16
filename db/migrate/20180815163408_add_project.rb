# create Project entity for use with future Holding Inst entity
class AddProject < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.string :fiscal_year
      t.string :hosting
      t.integer :storage_used
    end
    create_join_table :projects, :collections
  end
end
