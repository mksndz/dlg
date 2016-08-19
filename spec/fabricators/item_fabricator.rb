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
      %w(Athens Atlanta Augusta Macon).sample,
  ]}
  collection

end