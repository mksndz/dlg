module DcHelper

  def dc_fields
    %w(
      dc_title
      dc_format
      dc_publisher
      dc_identifier
      dc_right
      dc_contributor
      dc_coverage_temporal
      dc_coverage_spatial
      dc_date
      dc_source
      dc_subject
      dc_type
      dc_description
      dc_creator
      dc_language
      dc_relation
    )
  end

  def split_dc_params(params)
    params.each do |f,v| #todo refactor
      params[f] = v.strip.split("\n") if dc_fields.include? f
    end
  end

end