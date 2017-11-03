require 'faker'

Fabricator(:collection) do
  slug do
    Faker::Internet.slug(
      Faker::Lorem.sentence(3).chomp('.'),
      '-'
    )
  end
  display_title { Faker::Lorem.sentence(3) }
  short_description { Faker::Lorem.sentence(12) }
  dcterms_title do
    [Faker::Hipster.sentence(5),
     Faker::Hipster.sentence(4)]
  end
  dcterms_spatial ['United States, Georgia, Bibb County, 32.8064982, -83.69742']
  dcterms_provenance ['DLG']
  edm_is_shown_at ['http://dlg.galileo.usg.edu']
  edm_is_shown_by ['http://dlg.galileo.usg.edu']
  dcterms_type ['Collection']
end

Fabricator(:empty_collection, from: :collection) do
  repository(fabricator: :empty_repository)
  portals { |attrs| attrs[:repository].portals }
end

Fabricator(:collection_with_repo_and_item, from: :collection) do
  repository(fabricator: :empty_repository)
  portals { |attrs| attrs[:repository].portals }
  items(count: 1) do |attrs|
    Fabricate.build(:item, portals: attrs[:repository].portals)
  end
end