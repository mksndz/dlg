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
  dc_date ['1999-2000']
  dc_right [I18n.t('meta.rights.zero.uri')]
  dcterms_spatial ['United States, Georgia, Bibb County, 32.8064982, -83.69742']
  edm_is_shown_at ['http://dlg.galileo.usg.edu']
  edm_is_shown_by ['http://dlg.galileo.usg.edu']
  sponsor_note Faker::Lorem.sentence(5)
  sponsor_image File.open("#{Rails.root}/spec/files/snickers.jpg")
  dcterms_type ['Collection']
  holding_institutions(count: 1)
end

Fabricator(:empty_collection, from: :collection) do
  repository(fabricator: :empty_repository)
  portals { |attrs| attrs[:repository].portals }
end

Fabricator(:empty_collection_with_resource, from: :collection) do
  repository(fabricator: :empty_repository)
  portals { |attrs| attrs[:repository].portals }
  collection_resources(count:1)
end

Fabricator(:collection_with_repo_and_item, from: :collection) do
  repository(fabricator: :empty_repository)
  portals { |attrs| attrs[:repository].portals }
  items(count: 1) do |attrs|
    Fabricate.build(:robust_item, portals: attrs[:repository].portals)
  end
end
Fabricator(:collection_with_repo_and_robust_item, from: :collection) do
  repository(fabricator: :empty_repository)
  portals { |attrs| attrs[:repository].portals }
  items(count: 1) do |attrs|
    Fabricate.build(:robust_item, portals: attrs[:repository].portals)
  end
end