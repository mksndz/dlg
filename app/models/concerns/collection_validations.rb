# handles validation for Collection records
module CollectionValidations
  include MetadataHelper
  extend ActiveSupport::Concern

  included do
    validates_presence_of :repository, message: I18n.t('activerecord.errors.messages.collection.repository')
    validates_presence_of :display_title
    validates_uniqueness_of :slug, scope: :repository_id
    validates_presence_of :dcterms_title, :dcterms_provenance
    validate :dcterms_temporal_characters
    validate :dcterms_type_required_value
    validate :dc_date_characters
    validate :dc_right_present_and_valid
  end

  private

  def dc_right_present_and_valid
    if dc_right.empty?
      errors.add(:dc_right, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    errors.add(:dc_right, I18n.t('activerecord.errors.messages.dc_right_not_approved')) if (dc_right - all_rights_statements_uris).any?
  end

  def dc_date_characters
    if dc_date.empty? || dc_date.reject(&:blank?).empty?
      errors.add(:dc_date, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    dc_date.each do |v|
      if v =~ %r{([^0-9\/-])}
        errors.add(:dc_date, "#{I18n.t('activerecord.errors.messages.date_invalid_character')}: #{v}")
        break
      end
    end
  end

  def dcterms_temporal_characters
    dcterms_temporal.each do |v|
      if v =~ %r{([^0-9\/-])}
        errors.add(:dcterms_temporal, "#{I18n.t('activerecord.errors.messages.temporal_invalid_character')}: #{v}")
        break
      end
    end
  end

  def dcterms_type_required_value
    if dcterms_type.empty?
      errors.add(:dcterms_type, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    if (dcterms_type & dcmi_valid_types).empty?
      errors.add(:dcterms_type, I18n.t('activerecord.errors.messages.type_required_value'))
    end
  end
end