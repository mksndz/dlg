Fabricator(:holding_institution) do
  display_name { Faker::Hipster.sentence(3) }
  short_description { Faker::Hipster.sentence(5) }
  description { Faker::Hipster.sentence(10) }
  homepage_url { Faker::Internet.url }
  coordinates '31.978987, -81.161760'
  strengths { Faker::Hipster.sentence(3) }
  contact_information { Faker::Address.full_address }
  institution_type 'Museum'
  galileo_member false
  contact_name { Faker::Name.name }
  contact_email { Faker::Internet.email }
  harvest_strategy 'OAI'
  oai_urls { Faker::Internet.url }
  ignored_collections 'None'
  analytics_emails { [Faker::Internet.email, Faker::Internet.email] }
  subgranting { Faker::Hipster.sentence(2) }
  grant_partnerships { Faker::Hipster.sentence(2) }
end
