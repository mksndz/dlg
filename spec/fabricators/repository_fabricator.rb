require 'faker'

Fabricator(:repository) do

  portals(count: 1)
  slug { Faker::Internet.slug(Faker::Lorem.sentence(3).chomp('.'),'-') }
  title { Faker::Lorem.sentence(4) + ' Repo' }
  coordinates { '31.978987, -81.161760' }
  thumbnail_path { Faker::Internet.url }
  color { '#eeeeee' }

end