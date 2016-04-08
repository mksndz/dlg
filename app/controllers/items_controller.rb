class ItemsController < ApplicationController

  load_and_authorize_resource
  include ErrorHandling
  include DcHelper
  include Sorting
  include Searchable
  include MultipleActionable

  before_action :collections_for_select, only: [ :new, :copy, :edit ]

  def index

    # set_search_options

    set_filter_options

    if current_user.super?
          @items = Item.index_query(params)
              .order(sort_column + ' ' + sort_direction)
              .page(params[:page])
    else
          collection_ids = current_user.collection_ids || []
          collection_ids += current_user.repositories.map { |r| r.collection_ids }
          @items = Item.index_query(params)
                       .includes(:collection)
                       .where(collection: collection_ids.flatten)
                       .order(sort_column + ' ' + sort_direction)
                       .page(params[:page])
    end

    # if current_user.super?
    #   if params[:search]
    #     s = ItemSearch.search(params)
    #     @items = s.results
    #     # @count = s.total
    #   else
    #     @items = Item
    #         .order(sort_column + ' ' + sort_direction)
    #         .page(params[:page])
    #   end
    # else
    #   if params[:search]
    #     # todo user limits
    #     @items = ItemSearch.search params
    #   else
    #     collection_ids = current_user.collection_ids || []
    #     collection_ids += current_user.repositories.map { |r| r.collection_ids }
    #     @items = Item
    #                  .includes(:collection)
    #                  .where(collection: collection_ids.flatten)
    #                  .order(sort_column + ' ' + sort_direction)
    #                  .page(params[:page])
    #   end
    #
    # end

  end

  def show
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(split_dc_params(item_params))
    if @item.save
      redirect_to item_path(@item), notice: 'Item created'
    else
      collections_for_select
      render :new, alert: 'Error creating item'
    end
  end

  def copy
    @item = Item.new(@item.attributes.except(:id))
    render :edit
  end

  def edit
  end

  def update
    if @item.update(split_dc_params(item_params))
      redirect_to item_path(@item), notice: 'Item updated'
    else
      collections_for_select
      render :edit, alert: 'Error creating item'
    end
  end

  def destroy
    if @item.destroy
      redirect_to items_path, notice: 'Item destroyed.'
    else
      redirect_to items_path, alert: 'Item could not be destroyed.'
    end
  end

  private

  def collections_for_select
    @collections = Collection.all.order(:display_title)
  end

  def item_params
    params.require(:item).permit(
        :collection_id,
        :slug,
        :dpla,
        :public,
        :date_range,
        :dc_identifier,
        :dc_right,
        :dc_relation,
        :dc_format,
        :dc_date,
        :dcterms_is_part_of,
        :dcterms_contributor,
        :dcterms_creator,
        :dcterms_description,
        :dcterms_extent,
        :dcterms_medium,
        :dcterms_identifier,
        :dcterms_language,
        :dcterms_spatial,
        :dcterms_publisher,
        :dcterms_access_right,
        :dcterms_rights_holder,
        :dcterms_subject,
        :dcterms_temporal,
        :dcterms_title,
        :dcterms_type,
        :dcterms_is_shown_at,
        :dcterms_provenance,
        :dcterms_license,
        :other_collections  => [],
    )
  end

  # def set_search_options
  #   @search_options = {}
  #   @search_options[:public] = [['Public or Not Public', ''],['Public', '1'],['Not Public', '0']]
  #   @search_options[:dpla] = [['Yes or No', ''],['Yes', 1],['No', 0]]
  #   if current_user.super?
  #     @search_options[:collections] = Collection.all
  #     @search_options[:repositories] = Repository.all
  #   elsif current_user.basic?
  #     @search_options[:collections] = Collection.where(id: current_user.collection_ids)
  #     @search_options[:repositories] = Repository.where(id: current_user.repository_ids)
  #   end
  # end

  def set_filter_options
    @search_options = {}
    @search_options[:public] = [['Public or Not Public', ''],['Public', '1'],['Not Public', '0']]
    if current_user.super?
      @search_options[:collections] = Collection.all
      @search_options[:repositories] = Repository.all
    elsif current_user.basic?
      @search_options[:collections] = Collection.where(id: current_user.collection_ids)
      @search_options[:repositories] = Repository.where(id: current_user.repository_ids)
    end
  end
end
