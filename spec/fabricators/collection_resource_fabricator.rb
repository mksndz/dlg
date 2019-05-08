Fabricator(:collection_resource) do
  slug { Faker::Internet.slug }
  position 1
  title { Faker::Lorem.sentence(5) }
  content { Faker::Lorem.paragraphs(2) }
  collection { Fabricate :empty_collection }
end
