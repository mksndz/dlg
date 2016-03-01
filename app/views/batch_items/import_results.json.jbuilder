json.extract! @batch_item, :id
json.extract! @batch_item, :slug
json.edit_url batch_batch_item_url(@batch, @batch_item)