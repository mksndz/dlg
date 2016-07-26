class AddBibloCiteToColl < ActiveRecord::Migration
  def change

    change_table :collections do |t|
      t.text :dcterms_bibliographic_citation, array: true, null: false, default: []
    end

  end
end
