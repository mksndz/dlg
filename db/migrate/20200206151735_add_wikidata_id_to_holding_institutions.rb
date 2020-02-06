class AddWikidataIdToHoldingInstitutions < ActiveRecord::Migration
  def change
    add_column :holding_institutions, :wikidata_id, :string
  end
end
