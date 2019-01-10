require 'faker'

Fabricator(:page_ingest) do
  title { Faker::Hipster.words 3 }
  description { Faker::Hipster.words 7 }
  user
end

Fabricator(:page_ingest_with_json, from: :page_ingest) do
  queued_at { Faker::Time.between(Time.zone.today - 1, Time.zone.today) }
  page_json do
    [
      {
        id: 'a_b_c1',
        fulltext: 'First page fulltext',
        file_type: 'jp2',
        number: 1
      },
      {
        id: 'a_b_c2',
        fulltext: 'Second page fulltext',
        file_type: 'jp2',
        number: 2
      }
    ]
  end
end

Fabricator(:page_ingest_with_json_and_results, from: :page_ingest) do
  queued_at { Faker::Time.between(Time.zone.today - 1, Time.zone.today) }
  finished_at { Faker::Time.between(Time.zone.today, Time.zone.today + 1) }
  page_json do
    [
      {
        id: Fabricate(:item_with_parents).record_id,
        fulltext: 'First page fulltext',
        file_type: 'jp2',
        number: 1
      },
      {
        id: Fabricate(:item_with_parents).record_id,
        fulltext: 'Second page fulltext',
        file_type: 'jp2',
        number: 2
      }
    ]
  end
  results_json do
    {
      status: 'Success',
      message: '2 pages created',
      items: %w[r1_c1_i1 r1_c1_i2]
    }
  end
end