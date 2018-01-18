Fabricator(:feature) do
  title { Faker::Hipster.sentence }
  title_link { Faker::Internet.url }
  institution { Faker::University.name }
  institution_link { Faker::Internet.url }
  area 'carousel'
  primary false
end

Fabricator(:external_feature, from: :feature) do
  short_description { Faker::Hipster.sentence(12) }
  external_link { Faker::Internet.url }
end

Fabricator(:tab_feature, from: :feature) do
  area 'tabs'
end