require 'faker'

Fabricator(:collection) do

  slug { Faker::Internet.slug(Faker::Lorem.sentence(3).chomp('.'),'-') }
  display_title Faker::Lorem.sentence(3)
  items(count: 5)

end