class HoldingInstitution < ActiveRecord::Base
  has_and_belongs_to_many :repositories
  has_many :projects
  mount_uploader :image, ImageUploader

  def portals
    repositories.collect(&:portals).flatten.uniq
  end

  def collections
    Collection.where("? = ANY (dcterms_provenance)", display_name)
  end
end
