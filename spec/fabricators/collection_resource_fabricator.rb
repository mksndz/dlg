Fabricator(:collection_resource) do
  slug { Faker::Internet.slug.gsub('.', '-') }
  position { sequence(:position, 1) }
  title { Faker::Lorem.sentence(5) }
  raw_content { Faker::Lorem.paragraph(8) }
  collection { Fabricate :empty_collection }
end
