require 'faker'

Fabricator(:pending_invitation, from: :user) do
  email { Faker::Internet.email }
  roles { [Fabricate(:basic_role)] }
  invitation_created_at { Time.now }
  invitation_sent_at { Time.now }
end
