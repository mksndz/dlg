require 'faker'

Fabricator(:collection) do

  slug { Faker::Internet.slug(Faker::Lorem.sentence(3).chomp('.'),'-') }
  repository { Fabricate(:repository)}
  display_title { Faker::Lorem.sentence(3) }
  dcterms_title { [
      Faker::Hipster.sentence(5),
      Faker::Hipster.sentence(4)
  ] }
  dcterms_spatial { [
      'United States, Georgia, Bibb County, 32.8064982, -83.69742'
  ] }
  dcterms_provenance { [
      'DLG'
  ]}
  dcterms_is_shown_at { [
      'http://dlg.galileo.usg.edu'
  ]}
end