require 'faker'

test_results_hash = { 'items': [{ 'batch_item':1,'item':1,'slug':'test_slug' }] }

Fabricator(:batch) do
  name { Faker::Lorem.sentence }
  notes { Faker::Lorem.sentence }
  user { Fabricate(:user) }
end

Fabricator(:committed_batch, from: :batch) do
  committed_at { Time.now }
  queued_for_commit_at { Time.now }
  batch_items(count: 1)
  batch_items_count { 1 }
  commit_results { test_results_hash }
end

Fabricator(:batch_for_updating_record_id, from: :batch) do
  batch_imports do
    [Fabricate(:batch_import_for_updating_record_id)]
  end
end

Fabricator(:batch_from_search_results, from: :batch) do
  batch_imports { [Fabricate(:completed_batch_import_from_search_result)] }
end

Fabricator(:batch_that_failed_to_commit, from: :batch) do
  job_message { 'Failed' }
end