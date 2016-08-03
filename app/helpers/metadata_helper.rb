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

  # def rights_statements
  #   {
  #       inc: [
  #           'In Copyright',
  #           'http://rightsstatements.org/vocab/InC/1.0/'
  #       ],
  #       inc_ow_eu: [
  #           'In Copyright - EU Orphan Work',
  #           'http://rightsstatements.org/vocab/InC-OW-EU/1.0/'
  #       ],
  #       inc_edu: [
  #           'In Copyright - Educational Use Permitted',
  #           'http://rightsstatements.org/vocab/InC-EDU/1.0/'
  #       ],
  #       inc_enc: [
  #           'In Copyright - Non-Commercial Use Permitted',
  #           'http://rightsstatements.org/vocab/InC-NC/1.0/'
  #       ],
  #       inc_ruu: [
  #           'In Copyright - Rights-holder(s) Unlocatable or Unidentifiable',
  #           'http://rightsstatements.org/vocab/InC-RUU/1.0/'
  #       ],
  #       noc_cr: [
  #           'No Copyright - Contractual Restrictions',
  #           'http://rightsstatements.org/vocab/NoC-CR/1.0/'
  #       ],
  #       noc_nc: [
  #           'No Copyright - Non-Commercial Use Only',
  #           'http://rightsstatements.org/vocab/NoC-NC/1.0/'
  #       ],
  #       noc_oklr: [
  #           'No Copyright - Other Known Legal Restrictions',
  #           'http://rightsstatements.org/vocab/NoC-OKLR/1.0/'
  #       ],
  #       noc_us: [
  #           'No Copyright - United States',
  #           'http://rightsstatements.org/vocab/NoC-US/1.0/'
  #       ],
  #       cne: [
  #           'Copyright Not Evaluated',
  #           'http://rightsstatements.org/vocab/CNE/1.0/'
  #       ],
  #       und: [
  #           'Copyright Undetermined',
  #           'http://rightsstatements.org/vocab/UND/1.0/'
  #       ],
  #       nkc: [
  #           'No Known Copyright',
  #           'http://rightsstatements.org/vocab/NKC/1.0/'
  #       ],
  #   }
  # end

  def rights_statements
    {
        'In Copyright'                                                    => 'http://rightsstatements.org/vocab/InC/1.0/',
        'In Copyright - EU Orphan Work'                                   => 'http://rightsstatements.org/vocab/InC-OW-EU/1.0/',
        'In Copyright - Educational Use Permitted'                        => 'http://rightsstatements.org/vocab/InC-EDU/1.0/',
        'In Copyright - Non-Commercial Use Permitted'                     => 'http://rightsstatements.org/vocab/InC-NC/1.0/',
        'In Copyright - Rights-holder(s) Unlocatable or Unidentifiable'   => 'http://rightsstatements.org/vocab/InC-RUU/1.0/',
        'No Copyright - Contractual Restrictions'                         => 'http://rightsstatements.org/vocab/NoC-CR/1.0/',
        'No Copyright - Non-Commercial Use Only'                          => 'http://rightsstatements.org/vocab/NoC-NC/1.0/',
        'No Copyright - Other Known Legal Restrictions'                   => 'http://rightsstatements.org/vocab/NoC-OKLR/1.0/',
        'No Copyright - United States'                                    => 'http://rightsstatements.org/vocab/NoC-US/1.0/',
        'Copyright Not Evaluated'                                         => 'http://rightsstatements.org/vocab/CNE/1.0/',
        'Copyright Undetermined'                                          => 'http://rightsstatements.org/vocab/UND/1.0/',
        'No Known Copyright'                                              => 'http://rightsstatements.org/vocab/NKC/1.0/'
    }
  end

  def split_multivalued_params(params)
    params.each do |f,v| #todo refactor
      params[f] = v.strip.split("\n") if multivalued_fields.include? f
    end
  end

  def rights_statements_for_select
    rights_statements.map do |name, uri|
      ["#{name} (#{uri}}", name]
    end
  end

end

