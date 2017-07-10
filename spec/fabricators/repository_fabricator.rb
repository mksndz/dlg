require 'faker'

Fabricator(:repository) do

  slug { Faker::Internet.slug(Faker::Lorem.sentence(3).chomp('.'),'-') }
  title { Faker::Lorem.sentence(4) + ' Repo' }
  coordinates { '31.978987, -81.161760' }
  thumbnail_path { Faker::Internet.url }
  color { '#eeeeee' }
  # collections(count: 2)

end