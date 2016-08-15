require 'faker'

test_results_hash_with_error = {'items':[{'batch_item':1,'item':1,'slug':'test_slug'}],'errors':[{'batch_item':2,'errors': {'test_key':['test error message']}}]}
test_results_hash = {'items':[{'batch_item':1,'item':1,'slug':'test_slug'}],'errors':[]}

Fabricator(:batch) do
  name { Faker::Lorem.sentence }
  notes { Faker::Lorem.sentence }
  user { Fabricate(:user) }
end

Fabricator(:committed_batch_with_error, from: :batch) do
  committed_at { Time.now }
  queued_for_commit_at { Time.now }
  batch_items(count: 2)
  batch_items_count { 2 }
  commit_results { test_results_hash_with_error }
end

Fabricator(:committed_batch, from: :batch) do
  committed_at { Time.now }
  queued_for_commit_at { Time.now }
  batch_items(count: 1)
  batch_items_count { 1 }
  commit_results { test_results_hash }
end
