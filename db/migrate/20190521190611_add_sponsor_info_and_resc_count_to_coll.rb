# add some fields for Sponsor information and Resource count
class AddSponsorInfoAndRescCountToColl < ActiveRecord::Migration
  def change
    change_table :collections do |t|
      t.integer 'collection_resources_count'
      t.string 'sponsor_note'
      t.string 'sponsor_image'
    end
  end
end
