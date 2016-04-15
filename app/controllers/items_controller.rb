class ItemsController < ApplicationController

  load_and_authorize_resource
  include ErrorHandling
  include DcHelper
  include Sorting
  include Searchable
  include MultipleActionable
  include Filterable

  before_action :set_data, only: [ :new, :copy, :edit ]

  def index

    set_filter_options [:repository, :collection]

    if current_user.super?
        @items = Item.index_query(params)
                     .order(sort_column + ' ' + sort_direction)
                     .page(params[:page])
                     .per(params[:per_page])
    else
        @items = Item.index_query(params)
                     .includes(:collection)
                     .where(collection: user_collection_ids)
                     .order(sort_column + ' ' + sort_direction)
                     .page(params[:page])
                     .per(params[:per_page])
    end

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
      set_data
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
      set_data
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

  def set_data
    @data = {}
    @data[:collections] = Collection.all.order(:display_title)
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

end
