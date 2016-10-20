class RecordController < ApplicationController

  MULTIVALUED_TEXT_FIELDS = %w(
      dc_right
      dc_relation
      dc_format
      dc_date
      dcterms_is_part_of
      dcterms_contributor
      dcterms_creator
      dcterms_description
      dcterms_extent
      dcterms_medium
      dcterms_identifier
      dcterms_language
      dcterms_spatial
      dcterms_publisher
      dcterms_rights_holder
      dcterms_subject
      dcterms_temporal
      dcterms_title
      dcterms_is_shown_at
      dcterms_provenance
      dcterms_bibliographic_citation
      dlg_local_right
    )
  VALID_TYPES = %w(Collection Dataset MovingImage StillImage Interactive Resource Software Sound Text)
  RIGHTS_STATEMENTS = %w(inc inc_ow_eu inc_edu inc_nc inc_ruu noc_cr noc_nc noc_oklr noc_us cne und nkc zero mark by-nc-sa by-nc by-nd by-sa by)

  protected

  def prepare_params(params)
    params.each do |f,v|
      params[f] = v.reject(&:empty?) if v.kind_of? Array
      params[f] = v.strip.split("\n") if MULTIVALUED_TEXT_FIELDS.include? f
    end
  end

end
