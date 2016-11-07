require 'faker'

Fabricator(:subject) do
  name { Faker::Hipster.word.titleize }
end
