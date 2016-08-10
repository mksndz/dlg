module MetadataHelper

  def multivalued_fields
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
      dcterms_bibliographic_citation
      dlg_local_right
    )
  end

  def rights_statements
    %w(inc inc_ow_eu inc_edu inc_nc inc_ruu noc_cr noc_nc noc_oklr noc_us cne und nkc zero mark by-nc-sa by-nc by-nd by-sa by)
  end

  def split_multivalued_params(params)
    params.each do |f,v| #todo refactor
      params[f] = v.strip.split("\n") if multivalued_fields.include? f
    end
  end

  def all_rights_statements_for_select
    rights_statements.map do |r|
      [I18n.t(:label, scope: [:meta, :rights, r.to_sym]), I18n.t(:uri, scope: [:meta, :rights, r.to_sym])]
    end
  end

  def rights_icon_url(uri)
    # a simple lookup hash or pairs for doing this could be loaded into redis at app start
    I18n.t([:rights], scope: :meta)[0].each do |r|
      return r[1][:icon_url] if r[1][:uri] == uri
    end
    'Icon Not Found for ' + uri
  end

end

