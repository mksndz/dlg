module Searchable
  extend ActiveSupport::Concern

  included do
  end

  def search
    set_search_options
  end

  def results
    @data = {}
    if current_admin.super?
      s = search_class.search(params)
      @data[:results] = s.results
      @data[:count] = s.total
    else
      # todo user limits
      @data[:results] = search_class.search basic_user_params
    end
  end

  def search_class
    search_class_name = controller_path.singularize + '_search'
    search_class_name.classify.constantize
  end

  def basic_user_params
    new_params = params
    if params[:collection_id] and params[:collection_id].empty?
      new_params[:collection_id] = current_admin.collection_ids
    else
      # check_basic_admin_params
    end

    if params[:repository_id] and params[:repository_id].empty?
      new_params[:repository_id] = current_admin.repository_ids
    else
      # check_basic_admin_params
    end

    new_params
  end

  def basic_admin_collections
    collection_ids = current_admin.collection_ids || []
    collection_ids += current_admin.repositories.map { |r| r.collection_ids }
    collection_ids
  end

  def check_basic_admin_collection_param
    basic_admin_collections.includes? params[:collection_id]
  end

  def check_basic_admin_repository_param
    current_admin.repository_idss.includes? params[:repository_id]
  end

end