require 'faker'

Fabricator :batch_item do

  batch
  portals(count: 1)
  slug { Faker::Internet.slug(Faker::Lorem.sentence(3).chomp('.'),'-') }
  collection { Fabricate(:collection) }
  dcterms_title { [
      Faker::Lorem.sentence(5),
      Faker::Lorem.sentence(4)
  ] }
  dcterms_type { [
      %w(StillImage Text).sample
  ]}
  dcterms_subject { [
      %w(Athens Atlanta Augusta Macon).sample,
      'Georgia'
  ]}
  dc_date { [
      '1999-2000'
  ]}
  dc_right { [
      'CC NA'
  ]}
  dcterms_contributor { [
      'DLG'
  ]}
  dcterms_spatial { [
      %w(Athens Atlanta Augusta Macon).sample,
  ]}
  dcterms_provenance { [
      'DLG'
  ]}
  edm_is_shown_at { [
      'http://dlg.galileo.usg.edu'
  ]}
  edm_is_shown_by { [
      'http://dlg.galileo.usg.edu'
  ]}

end
