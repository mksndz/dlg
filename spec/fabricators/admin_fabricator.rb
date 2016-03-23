require 'faker'

Fabricator(:admin) do
  email { Faker::Internet.email }
  password { Faker::Internet.password(8,64) }
end

Fabricator(:basic, from: :admin) do
  roles { [Fabricate(:basic_role)] }
end

Fabricator(:coordinator, from: :admin) do
  roles { [Fabricate(:coordinator_role)] }
end

Fabricator(:committer, from: :admin) do
  roles { [Fabricate(:committer_role)] }
end

Fabricator(:super, from: :admin) do
  roles { [Fabricate(:super_role)] }
end
