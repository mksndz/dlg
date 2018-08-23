Fabricator(:project) do
  title { Faker::Hipster.sentence(5) }
  fiscal_year '2019'
  hosting 'archival'
  storage_used 100
end
