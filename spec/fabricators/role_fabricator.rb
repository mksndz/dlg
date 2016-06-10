require 'faker'

Fabricator(:role) do
  name { Faker::Hipster.word }
end

Fabricator(:super_role, from: :role) do
  name 'super'
end

Fabricator(:basic_role, from: :role) do
  name 'basic'
end

Fabricator(:coordinator_role, from: :role) do
  name 'coordinator'
end

Fabricator(:committer_role, from: :role) do
  name 'committer'
end

Fabricator(:committer_role, from: :role) do
  name 'uploader'
end
