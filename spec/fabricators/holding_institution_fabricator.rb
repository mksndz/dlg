Fabricator(:holding_institution) do
  slug { Faker::Internet.slug(nil, '-') }
  authorized_name { Faker::Hipster.sentence(3) }
  short_description { Faker::Hipster.sentence(5) }
  description { Faker::Hipster.sentence(10) }
  homepage_url { Faker::Internet.url }
  coordinates '31.978987, -81.161760'
  strengths { Faker::Hipster.sentence(3) }
  public_contact_address { Faker::Address.full_address }
  public_contact_email { Faker::Internet.email }
  public_contact_phone { Faker::PhoneNumber.phone_number }
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
  notes { Faker::Hipster.sentence(10) }
  parent_institution { Faker::University.name }
  image File.open("#{Rails.root}/spec/files/aarl.gif")
end
