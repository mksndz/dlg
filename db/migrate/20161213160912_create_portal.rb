class CreatePortal < ActiveRecord::Migration
  def change
    create_table :portals do |t|
      t.string :code
      t.text :name
    end
  end
end
