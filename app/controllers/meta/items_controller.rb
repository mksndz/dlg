module Meta
  class ItemsController < BaseController

    load_and_authorize_resource
    include ErrorHandling
    include DcHelper
    include Sorting
    layout 'admin'

    before_action :collections_for_select, only: [ :new, :copy, :edit ]

    def index
      @collections = Collection.all.order(:display_title)

      if current_user.admin?
        if params[:collection_id]
          @items = Item
                       .where(collection_id: params[:collection_id])
                       .order(sort_column + ' ' + sort_direction)
                       .page(params[:page])
        else
          @items = Item
                       .order(sort_column + ' ' + sort_direction)
                       .page(params[:page])
        end
      else
        collection_ids = current_user.collection_ids || []
        collection_ids += current_user.repositories.map { |r| r.collection_ids }
        @items = Item
                     .includes(:collection)
                     .where(collection: collection_ids.flatten)
                     .order(sort_column + ' ' + sort_direction)
                     .page(params[:page])
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
        redirect_to meta_item_path(@item), notice: 'Item created'
      else
        collections_for_select
        render :new, alert: 'Error creating item'
      end
    end

    def copy
      render :edit
    end

    def edit
    end

    def update
      if @item.update(split_dc_params(item_params))
        redirect_to meta_item_path(@item), notice: 'Item updated'
      else
        collections_for_select
        render :edit, alert: 'Error creating item'
      end
    end

    def destroy
      if @item.destroy
        redirect_to meta_items_path, notice: 'Item destroyed.'
      else
        redirect_to meta_items_path, alert: 'Item could not be destroyed.'
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
          :dc_title,
          :dc_format,
          :dc_publisher,
          :dc_identifier,
          :dc_right,
          :dc_contributor,
          :dc_coverage_spatial,
          :dc_coverage_temporal,
          :dc_date,
          :dc_source,
          :dc_subject,
          :dc_type,
          :dc_description,
          :dc_creator,
          :dc_language,
          :dc_relation,
          :other_collections  => [],
      )
    end
  end
end
