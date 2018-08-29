# represents a Holding Institution (dcterms_provenance value)
class HoldingInstitution < ActiveRecord::Base
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :collections
  has_and_belongs_to_many :items
  has_and_belongs_to_many :batch_items
  has_many :projects
  mount_uploader :image, ImageUploader

  before_destroy :confirm_unassigned

  def portals
    repositories.collect(&:portals).flatten.uniq
  end

  def collections
    Collection.where('? = ANY (dcterms_provenance)', display_name)
  end

  def items
    Item.where('? = ANY (dcterms_provenance)', display_name)
  end

  def confirm_unassigned
    return true unless  collections.empty? && items.empty?
    raise HoldingInstitutionInUseError, "Cannot delete Holding Institution as it remains assigned to #{items.length} Items and #{collections.length} Collections"
  end
end
