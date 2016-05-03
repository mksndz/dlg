json.extract! @batch_item, :slug
json.set! :errors do
  json.array! @errors
end
