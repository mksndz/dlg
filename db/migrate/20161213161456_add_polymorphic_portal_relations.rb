class AddPolymorphicPortalRelations < ActiveRecord::Migration
  def change

    create_table :portal_records do |t|

      t.references :portal, index: true
      t.references :portable, polymorphic: true, index: true

    end

  end
end
