module CollectionsHelper
  def invalid_items_count(collection)
    collection.items.select { |i| !i.valid? }.count
  end
end