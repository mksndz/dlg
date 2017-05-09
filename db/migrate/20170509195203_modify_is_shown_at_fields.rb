# rename existing is_shown_at field and add new is_shown_by under edm namespace
class ModifyIsShownAtFields < ActiveRecord::Migration
  def change
    %w(collections items batch_items).each do |table|
      change_table table do |t|
        t.rename :dcterms_is_shown_at, :edm_is_shown_at
        t.text :edm_is_shown_by, array: true, null: false, default: []
      end
    end
  end
end
