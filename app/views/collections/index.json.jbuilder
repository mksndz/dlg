json.array!(@collections) do |collection|
  json.extract! collection, :record_id, :items_count
end
