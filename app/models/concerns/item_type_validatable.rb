require 'uri'

# handles validation for Item and BatchItem records
module ItemTypeValidatable
  include MetadataHelper
  extend ActiveSupport::Concern

  included do
    before_save :update_validation_cache
    validates_presence_of :collection, message: I18n.t('activerecord.errors.messages.item_type.collection')
    validates_presence_of :dcterms_spatial, :dcterms_title, :dcterms_provenance
    validate :dcterms_temporal_characters
    validate :dcterms_type_required_value
    validate :subject_value_provided
    validate :dc_date_characters
    validate :url_in_edm_is_shown_at
    validate :url_in_is_shown_by_when_local
  end

  private

  def subject_value_provided
    if dcterms_subject.empty? && dlg_subject_personal.empty?
      errors.add(:dcterms_subject, I18n.t('activerecord.errors.messages.item_type.dcterms_subject'))
    end
  end

  def dc_date_characters
    if dc_date.empty?
      errors.add(:dc_date, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    dc_date.each do |v|
      if v =~ %r{([^0-9\/-])}
        errors.add(:dc_date, "#{I18n.t('activerecord.errors.messages.item_type.date_invalid_character')}: #{v}")
        break
      end
    end
  end

  def dcterms_temporal_characters
    dcterms_temporal.each do |v|
      if v =~ %r{([^0-9\/-])}
        errors.add(:dcterms_temporal, "#{I18n.t('activerecord.errors.messages.item_type.temporal_invalid_character')}: #{v}")
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
      errors.add(:dcterms_type, I18n.t('activerecord.errors.messages.item_type.type_required_value'))
    end
  end

  def url_in_edm_is_shown_at
    if edm_is_shown_at.empty?
      errors.add(:edm_is_shown_at, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    edm_is_shown_at.each do |v|
      unless valid_url? v
        errors.add(:edm_is_shown_at, "#{I18n.t('activerecord.errors.messages.item_type.invalid_url_provided')}: #{v}")
        break
      end
    end
  end

  def url_in_is_shown_by_when_local
    return unless local
    if edm_is_shown_by.empty?
      errors.add(:edm_is_shown_by, I18n.t('activerecord.errors.messages.item_type.edm_is_shown_by_when_local.blank'))
      return
    end
    edm_is_shown_by.each do |v|
      unless valid_url? v
        errors.add(:edm_is_shown_by, "#{I18n.t('activerecord.errors.messages.item_type.edm_is_shown_by_when_local.url')}: #{v}")
        break
      end
    end
  end

  def valid_url?(url)
    url =~ URI.regexp
  end

  def update_validation_cache
    self.valid_item = valid?
    true
  end
end