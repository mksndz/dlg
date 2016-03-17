require 'faker'

Fabricator(:batch) do
  name { Faker::Lorem.sentence(4) }
  notes { Faker::Lorem.sentence(10) }
  user { Fabricate(:user) }
end
