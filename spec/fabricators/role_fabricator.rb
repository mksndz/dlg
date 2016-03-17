require 'faker'

Fabricator(:role) do
  name { Faker::Hipster.words(2) }
end

Fabricator(:admin_role, class_name: :role) do
  name 'admin'
end

Fabricator(:basic_role, class_name: :role) do
  name 'basic'
end

Fabricator(:coordinator_role, class_name: :role) do
  name 'coordinator'
end

Fabricator(:committer_role, class_name: :role) do
  name 'committer'
end
