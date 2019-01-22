# represent a Page: an optional component of an Item
class Page < ActiveRecord::Base
  belongs_to :item, counter_cache: true
  validates :file_type, presence: true
  validates :number, presence: true
  validates :number, uniqueness: { scope: :item }
  validates :number, numericality: true
  mount_uploader :file, DigitalObjectUploader

  def iiif_info_link
    "#{iiif_link_with_id}/info.json"
  end

  def iiif_file_link
    "#{iiif_link_with_id}/full/full/0/default.jpg"
  end

  private

  def iiif_link_with_id
    "#{Rails.application.secrets.iiif_base_uri}#{iiif_identifier}"
  end

  def iiif_identifier
    id = item.record_id
    parts = id.split '_'
    page = number.rjust 4, '0'
    "dlg%2F#{parts[0]}%2F#{parts[1]}%2F#{id}%2F#{id}-#{page}.#{file_type}"
  end
end
