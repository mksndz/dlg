require 'faker'

Fabricator(:batch) do
  name Faker::Lorem.sentence(4)
  notes Faker::Lorem.sentence(10)
  user
  batch_items(count: 2)
end
