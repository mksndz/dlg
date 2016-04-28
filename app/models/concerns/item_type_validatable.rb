module ItemTypeValidatable
  extend ActiveSupport::Concern

  included do

    validates_presence_of :collection, message: ' must be selected'
    validates_presence_of :dcterms_temporal, :dcterms_spatial, :dc_right, :dcterms_contributor
    validate :dcterms_temporal_characters, :dcterms_type_required_value

  end

  private

  def dcterms_temporal_characters
    valid = false
    dcterms_temporal.each do |v|
      if v =~ // #todo determine RegExp
        valid = true
      end
    end
    unless valid
      errors.add(:dcterms_temporal, " contains an invalid character. Only 0-9, '/' and '-' allowed.")
    end
  end

  def dcterms_type_required_value
    valid = false
    dcterms_type.each do |v|
      if %w(Collection Dataset MovingImage StillImage Interactive Resource Software Sound Text).include?(v) and !valid
        valid = true
      end
    end
    unless valid
      errors.add(:dcterms_type, ' does not contain any required values.')
    end
  end

end