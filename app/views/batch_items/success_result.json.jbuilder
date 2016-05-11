json.extract! @batch_item, :id
json.extract! @batch_item, :slug
json.valid @batch_item.valid?
json.edit_url edit_batch_batch_item_url(@batch, @batch_item)