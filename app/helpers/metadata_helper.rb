module MetadataHelper

  # TODO: this data is also set in the base RecordController...
  def dcmi_valid_types
    %w(Collection Dataset MovingImage StillImage InteractiveResource Software Sound Text)
  end

  def multivalued_fields
    %w(
      dcterms_title
      dcterms_creator
      dcterms_contributor
      dcterms_subject
      dlg_subject_personal
      dcterms_description
      dcterms_identifier
      dcterms_publisher
      edm_is_shown_at
      edm_is_shown_by
      dc_date
      dcterms_temporal
      dcterms_spatial
      dc_format
      dcterms_is_part_of
      dc_right
      dcterms_rights_holder
      dlg_local_right
      dc_relation
      dcterms_type
      dcterms_medium
      dcterms_extent
      dcterms_language
      dcterms_bibliographic_citation
    )
  end

  def rights_statements
    %w(inc inc_ow_eu inc_edu inc_nc inc_ruu noc_cr noc_nc noc_oklr noc_us cne und nkc zero mark by-nc-sa by-nc by-nd by-sa by by-nc-nd)
  end

  def split_multivalued_params(params)
    params.each do |f,v| #todo refactor
      params[f] = v.strip.split("\n") if multivalued_fields.include? f
    end
  end

  def all_rights_statements_uris
    rights_statements.map do |r|
      I18n.t :uri, scope: [:meta, :rights, r.to_sym]
    end
  end

  def all_rights_statements_for_select
    rights_statements.map do |r|
      [I18n.t(:label, scope: [:meta, :rights, r.to_sym]), I18n.t(:uri, scope: [:meta, :rights, r.to_sym])]
    end
  end

  def rights_icon_tag(obj)
    # todo a simple lookup hash or pairs for doing this could be loaded into redis at app start
    I18n.t([:rights], scope: :meta)[0].each do |r|
      return link_to(image_tag(r[1][:icon_url], class: 'rights-statement-icon'), r[1][:uri], class: 'rights-statement-link') if r[1][:uri] == obj[:value].first
    end
    link_to obj[:value].first, obj[:value].first
  end

  def rights_icon_label(uri)
    I18n.t([:rights], scope: :meta)[0].each do |r|
      return r[1][:label] if r[1][:uri] == uri
    end
    uri # return uri if no match found
  end

  def portals_list(rec)
    names = rec.portals.collect { |p| sanitize(p.name) }
    names.join('<br />').html_safe
  end

end
