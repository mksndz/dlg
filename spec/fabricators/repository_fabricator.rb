require 'faker'

Fabricator(:repository) do

  slug { Faker::Internet.slug(Faker::Lorem.sentence(3).chomp('.'),'-') }
  title Faker::Lorem.sentence(4) + ' Repo'
  collections(count: 2)

end