require 'faker'

Fabricator(:page_ingest) do
  title { Faker::Hipster.sentence 3 }
  description { Faker::Hipster.sentence 7 }
  file File.open(Rails.root.join('spec', 'files', 'pages.json'))
  user
end

Fabricator(:queued_page_ingest, from: :page_ingest) do
  queued_at { Faker::Time.between(Date.today - 1, Date.today) }
end

Fabricator(:page_ingest_with_json, from: :page_ingest) do
  queued_at { Faker::Time.between(Time.zone.today - 1, Time.zone.today) }
  page_json do
    [
      { id: Fabricate(:item_with_parents).record_id,
        pages: [
          { fulltext: 'First page fulltext', file_type: 'jp2', number: 1 },
          { fulltext: 'Second page fulltext', file_type: 'jp2', number: 2 }
        ] },
      { id: Fabricate(:item_with_parents).record_id,
        pages: [
          { fulltext: 'First page fulltext', file_type: 'jp2', number: 1 }
        ] }
    ]
  end
end

Fabricator(:page_ingest_with_bad_id, from: :page_ingest) do
  queued_at { Faker::Time.between(Time.zone.today - 1, Time.zone.today) }
  page_json do
    [{ id: 'bad id',
       pages: [
         { fulltext: 'First page fulltext', file_type: 'jp2', number: 1 }
       ] },
     { id: Fabricate(:item_with_parents).record_id,
       pages: [
         { fulltext: 'First page fulltext', file_type: 'jp2', number: 1 }
       ] }]
  end
end

Fabricator(:page_ingest_with_bad_page, from: :page_ingest) do
  queued_at { Faker::Time.between(Time.zone.today - 1, Time.zone.today) }
  page_json do
    [
      { id: Fabricate(:item_with_parents).record_id,
        pages: [{ text: 'First page fulltext', file_type: 'jp2' }] }
    ]
  end
end

Fabricator(:page_ingest_with_json_and_mixed_results, from: :page_ingest) do
  queued_at { Faker::Time.between(Time.zone.today - 1, Time.zone.today) }
  finished_at { Faker::Time.between(Time.zone.today, Time.zone.today + 1) }
  results_json do
    {
      status: 'partial success',
      message: '2 pages created',
      outcomes: {
        failed: [
          { id: 'a_b_c', page_title: 'Failed Page Title',
            message: 'Could not import' }
        ],
        succeeded: [
          { id: 'a_b_c', title: 'Succeeded Page Title' },
          { id: 'a_b_d', title: 'Second Succeeded Page Title' }
        ]
      }
    }
  end
end

Fabricator(:page_ingest_with_json_and_success, from: :page_ingest) do
  queued_at { Faker::Time.between(Time.zone.today - 1, Time.zone.today) }
  finished_at { Faker::Time.between(Time.zone.today, Time.zone.today + 1) }
  results_json do
    {
      status: 'success', message: '2 pages created',
      outcomes: {
        succeeded: [
          { id: 'a_b_c', page_title: 'Succeeded Page Title' },
          { id: 'a_b_d', page_title: 'Second Succeeded Page Title' },
        ],
        failed: []
      }
    }
  end
end

Fabricator(:page_ingest_with_json_and_total_failure, from: :page_ingest) do
  queued_at { Faker::Time.between(Time.zone.today - 1, Time.zone.today) }
  finished_at { Faker::Time.between(Time.zone.today, Time.zone.today + 1) }
  results_json do
    {
      status: 'failed',
      message: 'Worker failed completely',
      outcomes: {
        succeeded: [],
        failed: []
      }
    }
  end
end
Fabricator(:page_ingest_with_json_and_failed_pages, from: :page_ingest) do
  queued_at { Faker::Time.between(Time.zone.today - 1, Time.zone.today) }
  finished_at { Faker::Time.between(Time.zone.today, Time.zone.today + 1) }
  results_json do
    {
      status: 'failed',
      message: 'All Pages failed to ingest',
      outcomes: {
        succeeded: [],
        failed: [
          { id: 'a_b_c', page_title: 'Failed Page Title',
            message: 'Could not import' },
          { id: 'a_b_c', page_title: 'Failed Page 2 Title',
            message: 'Could not import' }
        ]
      }
    }
  end
end
