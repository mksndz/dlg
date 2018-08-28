class HoldingInstitution < ActiveRecord::Base
  has_and_belongs_to_many :repositories
  has_many :projects
  mount_uploader :image, ImageUploader

  before_destroy :confirm_unassigned

  def portals
    repositories.collect(&:portals).flatten.uniq
  end

  def collections
    Collection.where("? = ANY (dcterms_provenance)", display_name)
  end

  def items
    Item.where("? = ANY (dcterms_provenance)", display_name)
  end

  def confirm_unassigned
    collections.any? || items.any?
  end
end
