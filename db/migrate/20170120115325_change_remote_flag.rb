class ChangeRemoteFlag < ActiveRecord::Migration
  def change

    change_table :items do |t|
      t.rename :remote, :local
    end

    change_table :batch_items do |t|
      t.rename :remote, :local
    end

    change_table :collections do |t|
      t.remove :remote
    end

  end
end
