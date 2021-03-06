Fabricator(:holding_institution) do
  slug { Faker::Internet.unique.slug(nil, '-') }
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
  last_harvested_at { Faker::Date.backward }
  analytics_emails { [Faker::Internet.email, Faker::Internet.email] }
  subgranting { Faker::Hipster.sentence(2) }
  grant_partnerships { Faker::Hipster.sentence(2) }
  training { Faker::Hipster.sentence(10) }
  site_visits { Faker::Hipster.sentence(9) }
  consultations { Faker::Hipster.sentence(8) }
  impact_stories { Faker::Hipster.sentence(7) }
  newspaper_partnerships { Faker::Hipster.sentence(6) }
  committee_participation { Faker::Hipster.sentence(5) }
  other { Faker::Hipster.sentence(4) }
  notes { Faker::Hipster.sentence(10) }
  parent_institution { Faker::University.name }
  image File.open("#{Rails.root}/spec/files/aarl.gif")
end
