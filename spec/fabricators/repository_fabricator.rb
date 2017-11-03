require 'faker'

Fabricator(:repository) do
  slug do
    Faker::Internet.slug(
      Faker::Lorem.sentence(3).chomp('.'),
      '-'
    )
  end
  title { Faker::Lorem.sentence(4) + ' Repo' }
  coordinates '31.978987, -81.161760'
  thumbnail_path { Faker::Internet.url }
  color '#eeeeee'
  portals(count: 1)
  collections(count: 1) do |attrs|
    Fabricate.build(
      :collection,
      portals: attrs[:portals],
      items: [Fabricate.build(:item, portals: attrs[:portals])]
    )
  end
end

Fabricator(:empty_repository, from: :repository) do
  collections []
end