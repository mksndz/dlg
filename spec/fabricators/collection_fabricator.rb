require 'faker'

Fabricator(:collection) do

  slug { Faker::Internet.slug(Faker::Lorem.sentence(3).chomp('.'),'-') }
  display_title { Faker::Lorem.sentence(3) }
  dcterms_title { [
      Faker::Hipster.sentence(5),
      Faker::Hipster.sentence(4)
  ] }
end