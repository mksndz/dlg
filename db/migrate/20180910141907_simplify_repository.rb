# move attributes from repo to holding institution models
class SimplifyRepository < ActiveRecord::Migration
  def up
    HoldingInstitution.delete_all
    # convert repos to holding institution prior to changing table
    Repository.all.each do |r|
      hi = HoldingInstitution.new
      hi.repositories << r
      hi.display_name = r.title
      hi.short_description = r.short_description
      hi.description = r.description
      hi.contact_information = r.contact
      hi.homepage_url = r.homepage_url
      hi.strengths = r.strengths
      hi.image = r.image
      hi.coordinates = r.coordinates
      hi.save(validate: false)
    end

    # create stub holding institutions from collection provenance values
    Collection.all.each do |c|
      c.dcterms_provenance.each do |p|
        next if HoldingInstitution.find_by_display_name(p)
        hi = HoldingInstitution.new
        hi.display_name = p
        hi.save(validate: false)
      end
    end

    # remove tables no longer needed on repo model
    change_table :repositories do |t|
      t.rename :description, :notes
      t.remove :homepage_url
      t.remove :directions_url
      t.remove :short_description
      t.remove :address
      t.remove :strengths
      t.remove :contact
      t.remove :coordinates
      t.remove :image
      t.remove :thumbnail
      t.remove :dpla
      t.remove :teaser
    end
  end

  def down
    change_table :repositories do |t|
      t.rename :notes, :description
      t.string 'homepage_url'
      t.string 'directions_url'
      t.text 'short_description'
      t.text 'address'
      t.text 'strengths'
      t.text 'contact'
      t.boolean 'dpla', default: false, null: false
      t.string 'coordinates'
      t.boolean 'teaser'
      t.string 'thumbnail'
      t.string 'image'
    end
  end
end
