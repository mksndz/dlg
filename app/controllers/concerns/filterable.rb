module Filterable
  extend ActiveSupport::Concern

  private

  def set_filter_options(parameters = [])
    @search_options = {}
    @search_options[:public] = [['Public or Not Public', ''],['Public', '1'],['Not Public', '0']] if parameters.include? :public
    @search_options[:status] = [%w(Committed committed), %w(Pending pending)] if parameters.include? :status
    @search_options[:valid_item] = [['Any', ''], %w(Valid true), %w(Invalid false)] if parameters.include? :valid_item
    if current_user.super?
      @search_options[:collections] = Collection.select(:id, :display_title).order(:display_title) if parameters.include? :collection
      @search_options[:repositories] = Repository.select(:id, :title).order(:title) if parameters.include? :repository
      @search_options[:users] = User.all if parameters.include? :user
    else
      @search_options[:collections] = Collection.select(:id, :display_title).where(id: current_user.collection_ids).order(:display_title) if parameters.include? :collection
      @search_options[:repositories] = Repository.select(:id, :title).where(id: current_user.repository_ids).order(:title) if parameters. include? :repository
      @search_options[:users] = User.where(creator_id: current_user.id) if parameters.include? :user
    end
  end

  def user_collection_ids
    collection_ids = current_user.collection_ids || []
    collection_ids += current_user.repositories.map { |r| r.collection_ids }
    collection_ids.flatten
  end

end