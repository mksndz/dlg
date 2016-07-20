class SimpleRoles < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :is_super,       null: false, default: false, index: true
      t.boolean :is_coordinator, null: false, default: false, index: true
      t.boolean :is_committer,   null: false, default: false, index: true
      t.boolean :is_uploader,    null: false, default: false, index: true
    end
  end
end
