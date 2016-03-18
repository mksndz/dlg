require 'faker'

Fabricator(:user) do
  email { Faker::Internet.email }
  password { Faker::Internet.password(8,64) }
end

Fabricator(:basic, from: :user) do
  roles { [Fabricate(:basic_role)] }
end

Fabricator(:coordinator, from: :user) do
  roles { [Fabricate(:coordinator_role)] }
end

Fabricator(:committer, from: :user) do
  roles { [Fabricate(:committer_role)] }
end

Fabricator(:admin, from: :user) do
  roles { [Fabricate(:admin_role)] }
end
