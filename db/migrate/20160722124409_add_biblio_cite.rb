class AddBiblioCite < ActiveRecord::Migration
  def change

    change_table :items do |t|
      t.text :dcterms_bibliographic_citation, array: true, null: false, default: []
    end

    change_table :batch_items do |t|
      t.text :dcterms_bibliographic_citation, array: true, null: false, default: []
    end

  end
end
