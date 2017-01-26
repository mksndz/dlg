require 'faker'

Fabricator(:item) do

  slug { Faker::Internet.slug(Faker::Lorem.sentence(3).chomp('.'),'-') }
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
      I18n.t('meta.rights.zero.uri')
  ]}
  dcterms_contributor { [
      'DLG'
  ]}
  dcterms_spatial { [
      'United States, Georgia, Clarke County, Athens, 33.960948, -83.3779358'
  ]}
  collection

end

Fabricator(:item_with_two_spatial_values, from: :item) do

  dcterms_spatial { [
      'United States, Georgia, Clarke County, Athens, 33.960948, -83.3779358',
      'United States, Georgia, Fulton County, 33.7902836, -84.466986'
  ] }

end

Fabricator(:robust_item, from: :item) do

  dcterms_is_shown_at { [
      Faker::Internet.url
  ] }

  dcterms_identifier { [
      Faker::Internet.url
  ] }

  dlg_subject_personal { [
      Faker::Name.name_with_middle
  ] }

end