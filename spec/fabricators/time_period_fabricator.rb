require 'faker'

Fabricator(:time_period) do
  name { Faker::Hipster.word }
end
