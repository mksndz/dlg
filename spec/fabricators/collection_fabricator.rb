require 'faker'

Fabricator(:collection) do
  portals(count: 1)
  slug do
    Faker::Internet.slug(
      Faker::Lorem.sentence(3).chomp('.'),
      '-'
    )
  end
  repository { Fabricate(:repository) }
  display_title { Faker::Lorem.sentence(3) }
  short_description { Faker::Lorem.sentence(12) }
  dcterms_title do
    [Faker::Hipster.sentence(5),
     Faker::Hipster.sentence(4)]
  end
  dcterms_spatial do
    ['United States, Georgia, Bibb County, 32.8064982, -83.69742']
  end
  dcterms_provenance { ['DLG'] }
  edm_is_shown_at { ['http://dlg.galileo.usg.edu'] }
  edm_is_shown_by { ['http://dlg.galileo.usg.edu'] }
  dcterms_type { ['Collection'] }
end