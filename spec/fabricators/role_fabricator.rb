require 'faker'

Fabricator(:role) do
  name Faker::Hipster.words(2)
end
