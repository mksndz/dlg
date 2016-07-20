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

Fabricator(:committer, from: :user) do
  is_committer { true }
end

Fabricator(:uploader, from: :user) do
  is_uploader { true }
end

# todo to support legacy code, remove
Fabricator(:basic, from: :user)

# Fabricator(:basic, from: :user) do
#   roles { [Fabricate(:basic_role)] }
# end
#
# Fabricator(:coordinator, from: :user) do
#   roles { [Fabricate(:coordinator_role), Fabricate(:basic_role)] }
# end
#
# Fabricator(:committer, from: :user) do
#   roles { [Fabricate(:committer_role), Fabricate(:basic_role)] }
# end
#
# Fabricator(:uploader, from: :user) do
#   roles { [Fabricate(:uploader_role), Fabricate(:basic_role)] }
# end
#
# Fabricator(:super, from: :user) do
#   roles { [Fabricate(:super_role), Fabricate(:basic_role)] }
# end
