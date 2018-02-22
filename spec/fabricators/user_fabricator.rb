require 'faker'

Fabricator(:user) do
  email { Faker::Internet.email }
  password { Faker::Internet.password(8,64) }
end

Fabricator(:super, from: :user) do
  is_super { true }
end

Fabricator(:coordinator, from: :user) do
  is_coordinator { true }
end

Fabricator(:coordinator_committer, from: :user) do
  is_coordinator { true }
  is_committer { true }
end

Fabricator(:committer, from: :user) do
  is_committer { true }
end

Fabricator(:uploader, from: :user) do
  is_uploader { true }
end

# todo to support legacy code, remove
Fabricator(:basic, from: :user)