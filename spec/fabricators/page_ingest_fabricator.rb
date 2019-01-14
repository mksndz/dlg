require 'faker'

Fabricator(:page_ingest) do
  title { Faker::Hipster.sentence 3 }
  description { Faker::Hipster.sentence 7 }
  file File.open(Rails.root.join('spec', 'files', 'pages.json'))
  user
end

Fabricator(:page_ingest_with_json, from: :page_ingest) do
  queued_at { Faker::Time.between(Time.zone.today - 1, Time.zone.today) }
  page_json do
    [
      {
        id: Fabricate(:item_with_parents).record_id,
        pages: [
          {
            fulltext: 'First page fulltext',
            file_type: 'jp2',
            number: 1
          },
          {
            fulltext: 'Second page fulltext',
            file_type: 'jp2',
            number: 2
          }
        ]
      },
      {
        id: Fabricate(:item_with_parents).record_id,
        pages: [
          {
            fulltext: 'First page fulltext',
            file_type: 'jp2',
            number: 1
          }
        ]
      }
    ]
  end
end

Fabricator(:page_ingest_with_bad_json, from: :page_ingest) do
  queued_at { Faker::Time.between(Time.zone.today - 1, Time.zone.today) }
  page_json do
    [
      {
        id: Fabricate(:item_with_parents).record_id,
        pages: [
          {
            fulltext: 'First page fulltext',
            file_type: 'jp2',
            number: 1
          },
          {
            fulltext: 'Second page fulltext',
            file_type: 'jp2',
            number: 2
          }
        ]
      },
      {
        id: Fabricate(:item_with_parents).record_id,
        pages: [
          {
            fulltext: 'First page fulltext',
            file_type: 'jp2',
            number: 1
          }
        ]
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
        pages: [
          {
            fulltext: 'First page fulltext',
            file_type: 'jp2',
            number: 1
          },
          {
            fulltext: 'Second page fulltext',
            file_type: 'jp2',
            number: 2
          }
        ]
      },
      {
        id: Fabricate(:item_with_parents).record_id,
        pages: [
          {
            fulltext: 'First page fulltext',
            file_type: 'jp2',
            number: 1
          }
        ]
      }
    ]
  end
  results_json do
    {
      status: 'Success',
      message: '2 pages created',
      items: [Item.last.record_id, Item.find(Item.last.id - 1).record_id]
    }
  end
end