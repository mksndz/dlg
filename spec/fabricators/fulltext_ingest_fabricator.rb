require 'faker'

Fabricator(:fulltext_ingest) do
  title { Faker::Hipster.sentence(2) }
  description { Faker::Hipster.sentence(7) }
  user { Fabricate :super }
  file { Faker::File.file_name }
end

Fabricator(:completed_fulltext_ingest_success, from: :fulltext_ingest) do
  queued_at { Faker::Time(Date.now - 1, Date.now) }
  finished_at { Faker::Time(Date.now, Date.now + 1) }
  results do
    {
      status: 'success',
      files: {
        r1_c1_i1: { status: 'success', item: Fabricate(:item).id },
        r1_c1_i2: { status: 'failed', reason: 'Exception message' }
      }
    }
  end
end

Fabricator(:completed_fulltext_ingest_with_errors, from: :fulltext_ingest) do
  queued_at { Faker::Time(Date.now - 1, Date.now) }
  finished_at { Faker::Time(Date.now, Date.now + 1) }
  results do
    {
      status: 'partial failure',
      files: {
        r1_c1_i1: { status: 'success', item: Fabricate(:item).id },
        r1_c1_i2: { status: 'failed', reason: 'Exception message' }
      }
    }
  end
end

Fabricator(:completed_fulltext_ingest_total_failure, from: :fulltext_ingest) do
  queued_at { Faker::Time(Date.now - 1, Date.now) }
  finished_at { Faker::Time(Date.now, Date.now + 1) }
  results do
    {
      status: 'failed',
      files: {
        r1_c1_i1: { status: 'failed', reason: 'Exception message' },
        r1_c1_i2: { status: 'failed', reason: 'Exception message' }
      }
    }
  end
end

Fabricator(:queued_fulltext_ingest, from: :fulltext_ingest) do
  queued_at { Faker::Time(Date.now - 1, Date.now) }
end

Fabricator(:undone_fulltext_ingest, from: :fulltext_ingest) do
  queued_at { Faker::Time(Date.now - 1, Date.now) }
  undone_at { Faker::Time(Date.now, Date.now + 1) }
end