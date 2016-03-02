class RenameDcRights < ActiveRecord::Migration
  def change

    change_table :items do |t|
      t.rename :dc_rights, :dc_right
    end

    change_table :batch_items do |t|
      t.rename :dc_rights, :dc_right
    end

    change_table :collections do |t|
      t.rename :dc_rights, :dc_right
    end

  end
end
