# handles cleanup tasks for Item and BatchItem records
module ItemTypeCleaner
  include MetadataHelper
  extend ActiveSupport::Concern

  included do
    before_save :clean_up_metadata
  end

  private

  def clean_up_metadata
    convert_br_tags
    strip_tags HTML::FullSanitizer.new
  end

  def strip_tags(s)
    multivalued_fields.each do |field|
      strip_tags_from field, s
    end
  end

  def strip_tags_from(field, s)
    send(field).map! do |v|
      strip_tags_from_string v, s
    end
  end

  def strip_tags_from_string(value, s)
    s.sanitize value
  end

  def convert_br_tags
    multivalued_fields.each do |field|
      send(field).each do |val|
        val.gsub! %r{<br>|<br />|<br/>|<BR>|<BR />|<BR/>}, "\n"
      end
    end
  end
end