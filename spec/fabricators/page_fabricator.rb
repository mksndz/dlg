Fabricator(:page) do
  number { Fabricate.sequence(:pages, 1) }
  file_type 'jpg'
  title { Faker::Hipster.sentence }
end

Fabricator(:page_with_item, from: :page) do
  item { Fabricate(:item_with_parents) }
end

Fabricator(:page_with_item_and_text, from: :page_with_item) do
  fulltext { Faker::Hipster.sentences(5) }
end
