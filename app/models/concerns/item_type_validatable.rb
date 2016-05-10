module ItemTypeValidatable
  extend ActiveSupport::Concern

  TYPE_REQUIRED_VALUES = %w(Collection Dataset MovingImage StillImage Interactive Resource Software Sound Text)

  included do

    validates_presence_of :collection, message: ' must be selected'
    validates_presence_of :dcterms_temporal, :dcterms_spatial, :dc_right, :dcterms_contributor
    validate :dcterms_temporal_characters, :dcterms_type_required_value

  end

  private

  def dcterms_temporal_characters
    unless dcterms_temporal
      errors.add(:dcterms_temporal, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    dcterms_temporal.each do |v|
      if v =~ /([^0-9\/-])/
        errors.add(:dcterms_temporal, I18n.t('activerecord.errors.messages.temporal_invalid_character'))
        return
      end
    end
  end

  def dcterms_type_required_value
    unless dcterms_type
      errors.add(:dcterms_type, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    if (dcterms_type & TYPE_REQUIRED_VALUES).empty?
      errors.add(:dcterms_type, I18n.t('activerecord.errors.messages.type_required_value'))
    end
  end

end