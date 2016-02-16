require 'faker'

Fabricator(:user) do
  email Faker::Internet.email
  password Faker::Internet.password(8,64)
end
