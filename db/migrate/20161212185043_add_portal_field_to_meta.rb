class AddPortalFieldToMeta < ActiveRecord::Migration
  def change

    change_table :items do |t|
      t.string :portal
    end

    change_table :collections do |t|
      t.string :portal
    end

    change_table :repositories do |t|
      t.string :portal
    end

    change_table :batch_items do |t|
      t.string :portal
    end

    portal_value = 'dlg'

    Repository.all.each { |r| r.portal = portal_value }
    Collection.all.each { |r| r.portal = portal_value }
    Item.all.each       { |r| r.portal = portal_value }
    BatchItem.all.each  { |r| r.portal = portal_value }

  end
end
