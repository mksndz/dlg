# handles cleanup tasks for Item and BatchItem records
module ItemTypeCleaner
  extend ActiveSupport::Concern
  included { before_create :clean_up_metadata }
  def clean_up_metadata
    MetadataCleaner.new.clean self
  end
end