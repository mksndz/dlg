module Filterable
  extend ActiveSupport::Concern

  private

  def set_filter_options(entities = [])
    @search_options = {}
    @search_options[:public] = [['Public or Not Public', ''],['Public', '1'],['Not Public', '0']]
    if current_user.super?
      @search_options[:collections] = Collection.all if entities.include? :collection
      @search_options[:repositories] = Repository.all if entities. include? :repository
    elsif current_user.basic?
      @search_options[:collections] = Collection.where(id: current_user.collection_ids) if entities.include? :collection
      @search_options[:repositories] = Repository.where(id: current_user.repository_ids) if entities. include? :repository
    end
  end

  def user_collection_ids
    collection_ids = current_user.collection_ids || []
    collection_ids += current_user.repositories.map { |r| r.collection_ids }
    collection_ids.flatten
  end

end