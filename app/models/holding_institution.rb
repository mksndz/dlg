# represents a Holding Institution (dcterms_provenance value)
class HoldingInstitution < ActiveRecord::Base
  include IndexFilterable

  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :collections
  has_and_belongs_to_many :items
  has_and_belongs_to_many :batch_items
  has_many :projects

  mount_uploader :image, ImageUploader

  before_destroy :confirm_unassigned

  validates_presence_of :display_name, :institution_type
  validates_uniqueness_of :display_name

  def self.index_query_fields
    %w[institution_type]
  end

  def portal_names
    repositories.collect(&:portals).flatten.uniq.collect(&:name)
  end

  def confirm_unassigned
    return true if collections.empty? && items.empty?
    raise HoldingInstitutionInUseError, "Cannot delete Holding Institution as it remains assigned to #{items.length} Items and #{collections.length} Collections"
  end
end
