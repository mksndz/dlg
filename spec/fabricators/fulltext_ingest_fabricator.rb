require 'faker'

Fabricator(:fulltext_ingest) do
  title { Faker::Hipster.words(2) }
  description { Faker::Hipster.sentence(7) }
  user { Fabricate :super }
  file { Faker::File.file_name }
end

Fabricator(:completed_fulltext_ingest_success, from: :fulltext_ingest) do
  queued_at { Faker::Time(Date.now - 1, Date.now) }
  finished_at { Faker::Time(Date.now, Date.now + 1) }
  outcome do |attrs|
    {
      attrs[:file].to_sym => { status: 'success', item: Fabricate(:item).id }
    }
  end
end

Fabricator(:completed_fulltext_ingest_with_errors, from: :fulltext_ingest) do
  queued_at
  finished_at
  outcome
end

Fabricator(:completed_fulltext_ingest_total_failure, from: :fulltext_ingest) do
  queued_at
  finished_at
  outcome
end

Fabricator(:queued_fulltext_ingest, from: :fulltext_ingest) do
  queued_at
end

Fabricator(:undone_fulltext_ingest, from: :fulltext_ingest) do
  queued_at
  undone_at
end