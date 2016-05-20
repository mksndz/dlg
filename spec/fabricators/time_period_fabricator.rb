require 'faker'

Fabricator(:time_period) do
  name { Faker::Hipster.word }
  start { Faker::Number.number(4) }
  finish { Faker::Number.number(4) }
end
