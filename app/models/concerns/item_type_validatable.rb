require 'uri'

module ItemTypeValidatable
  include MetadataHelper
  extend ActiveSupport::Concern

  included do

    after_save :update_validation_cache

    validates_presence_of :collection, message: I18n.t('activerecord.errors.messages.item_type.collection')
    validates_presence_of :dcterms_spatial, :dcterms_title, :dcterms_provenance
    validate :dcterms_temporal_characters
    validate :dcterms_type_required_value
    validate :subject_value_provided
    validate :dc_date_characters
    validate :url_in_dcterms_is_shown_at

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
      if v =~ /([^0-9\/-])/
        errors.add(:dcterms_temporal, I18n.t('activerecord.errors.messages.item_type.temporal_invalid_character'))
        break
      end
    end
  end

  def dcterms_temporal_characters
    unless dcterms_temporal
      errors.add(:dcterms_temporal, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    dcterms_temporal.each do |v|
      if v =~ /([^0-9\/-])/
        errors.add(:dcterms_temporal, I18n.t('activerecord.errors.messages.item_type.temporal_invalid_character'))
        break
      end
    end
  end

  def dcterms_type_required_value
    unless dcterms_type
      errors.add(:dcterms_type, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    if (dcterms_type & dcmi_valid_types).empty?
      errors.add(:dcterms_type, I18n.t('activerecord.errors.messages.item_type.type_required_value'))
    end
  end

  def url_in_dcterms_is_shown_at
    if dcterms_is_shown_at.empty?
      errors.add(:dcterms_is_shown_at, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    dcterms_is_shown_at.each do |v|
      unless valid_url? v
        errors.add(:dcterms_is_shown_at, I18n.t('activerecord.errors.messages.item_type.invalid_url_provided'))
        break
      end
    end
  end

  def update_validation_cache
    update_columns valid_item: valid?
  end

end