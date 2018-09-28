# move attributes from repo to holding institution models
class SimplifyRepository < ActiveRecord::Migration
  def up
    HoldingInstitution.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('holding_institutions')
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
      hi.image = r.image.file unless r.image.file.nil?
      hi.coordinates = r.coordinates
      hi.save(validate: false)
    end
    # create stub holding institutions from collection provenance values
    # also set collection -> hi relations at this time
    Collection.all.each do |c|
      has_his = false
      c.legacy_dcterms_provenance.each do |p|
        has_his = true
        ehi = HoldingInstitution.find_by_display_name(p)
        if ehi
          c.holding_institutions << ehi
          next
        end
        hi = HoldingInstitution.new
        hi.display_name = p
        hi.save(validate: false)
        c.holding_institutions << hi
      end
      c.save(validate: false) if has_his
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
    end
  end
end
