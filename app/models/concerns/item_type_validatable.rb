module ItemTypeValidatable
  extend ActiveSupport::Concern

  included do

    validates_presence_of :collection, message: ' could not be set'
    validates_presence_of :dcterms_temporal
    validates_presence_of :dcterms_spatial
    validates_presence_of :dc_right
    validates_presence_of :dcterms_contributor
    # dcterms_temporal contains only (0-9, / or -)
    # dc_type(?) contains one of (Collection Dataset MovingImage StillImage Interactive Resource Software Sound Text)

  end

end