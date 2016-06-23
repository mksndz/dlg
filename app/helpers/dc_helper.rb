module DcHelper

  def dc_fields
    %w(
      dc_identifier
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
      dcterms_type
      dcterms_is_shown_at
      dcterms_provenance
    )
  end

  def split_dc_params(params)
    params.each do |f,v| #todo refactor
      params[f] = v.strip.split("\n") if dc_fields.include? f
    end
  end

end

