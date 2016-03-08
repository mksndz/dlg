require 'faker'

Fabricator(:role) do
  name Faker::Hipster.words(2)
end

Fabricator(:admin_role, from: :role) do
  name 'admin'
end

Fabricator(:basic_role, from: :role) do
  name 'basic'
end
