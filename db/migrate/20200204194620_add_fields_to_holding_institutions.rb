class AddFieldsToHoldingInstitutions < ActiveRecord::Migration
  def change
    add_column :holding_institutions, :training, :text
    add_column :holding_institutions, :site_visits, :text
    add_column :holding_institutions, :consultations, :text
    add_column :holding_institutions, :impact_stories, :text
    add_column :holding_institutions, :newspaper_partnerships, :text
    add_column :holding_institutions, :committee_participation, :text
    add_column :holding_institutions, :other, :text
  end
end
