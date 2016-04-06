json.array!(@batch_items) do |batch_item|
  json.extract! batch_item, :id
  json.url batch_item_url(batch_item, format: :json)
end
