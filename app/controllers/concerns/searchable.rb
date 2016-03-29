module Searchable
  extend ActiveSupport::Concern

  included do
  end

  def search
    set_search_options
  end

  def results
    if current_admin.super?
      s = search_class.search(params)
      @results = s.results
      # @count = s.total
    else
      if params[:search]
        # todo user limits
        @results = search_class.search params
      else
        # collection_ids = current_admin.collection_ids || []
        # collection_ids += current_admin.repositories.map { |r| r.collection_ids }
        # @items = Item
        #              .includes(:collection)
        #              .where(collection: collection_ids.flatten)
        #              .order(sort_column + ' ' + sort_direction)
        #              .page(params[:page])
      end

    end

    render :results
  end

  def search_class
    search_class_name = controller_path.singularize + '_search'
    search_class_name.classify.constantize
  end

end