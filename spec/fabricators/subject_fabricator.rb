require 'faker'

Fabricator(:subject) do
  name { Faker::Hipster.words 2 }
end
