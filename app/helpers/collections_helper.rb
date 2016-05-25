module CollectionsHelper
  def invalid_items_count(collection)
    collection.items.select { |i| !i.valid? }.count
  end

  def solr_items_count(collection)
    Item.search do
      with(:collection_id, collection.id)
      adjust_solr_params do |params|
        params[:q] = ''
      end
    end.total
  end
end