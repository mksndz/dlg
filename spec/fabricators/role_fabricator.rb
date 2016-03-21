require 'faker'

Fabricator(:role, from: 'Admin::Role') do
  name { Faker::Hipster.words(2) }
end

Fabricator(:admin_role, from: :role) do
  name 'admin'
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
