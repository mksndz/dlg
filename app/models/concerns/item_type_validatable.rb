module ItemTypeValidatable
  extend ActiveSupport::Concern

  included do

    validates_presence_of :collection, message: ' must be selected'
    validates_presence_of :dcterms_temporal, :dcterms_spatial, :dc_right, :dcterms_contributor
    validate :dcterms_temporal_characters, :dcterms_type_required_value

  end

  private

  def dcterms_temporal_characters
    dcterms_temporal.each do |v|
      if v =~ /([^0-9\/-])/
        errors.add(:dcterms_temporal, " contains an invalid character. Only 0-9, '/' and '-' allowed.")
        return
      end
    end
  end

  def dcterms_type_required_value
    dcterms_type.each do |v|
      unless %w(Collection Dataset MovingImage StillImage Interactive Resource Software Sound Text).include?(v)
        errors.add(:dcterms_type, ' does not contain any required values.')
        return
      end
    end
  end

end