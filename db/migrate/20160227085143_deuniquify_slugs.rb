class DeuniquifySlugs < ActiveRecord::Migration
  def change

    change_table :collections do |t|

      t.remove :slug

      t.string :slug, null: false
      t.index :slug

    end

    change_table :items do |t|

      t.remove :slug

      t.string :slug, null: false
      t.index :slug

    end

    change_table :batch_items do |t|

      t.remove :slug

      t.string :slug, null: false
      t.index :slug

    end

  end
end
