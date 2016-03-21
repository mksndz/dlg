require 'faker'

Fabricator(:subject, from: 'Admin::Subject') do
  name { Faker::Hipster.words 2 }
end
