class AddPublicFlagToCollection < ActiveRecord::Migration
  def change

    change_table :collections do |t|
      t.boolean :public,        null: false, default: false, index: true
    end
  end
end
