require 'faker'

Fabricator(:user) do
  email Faker::Internet.email
  password Faker::Internet.password(8,64)
end

Fabricator(:basic, from: :user) do
  email Faker::Internet.email
  password Faker::Internet.password(8,64)
  roles { [Fabricate(:basic_role)] }
end

Fabricator(:admin, from: :user) do
  email Faker::Internet.email
  password Faker::Internet.password(8,64)
  roles { [Fabricate(:admin_role)] }
end
