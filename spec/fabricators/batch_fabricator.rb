require 'faker'

Fabricator(:batch, from: 'Meta::Batch') do
  name { Faker::Lorem.sentence(4) }
  notes { Faker::Lorem.sentence(10) }
  admin { Fabricate(:admin) }
end
