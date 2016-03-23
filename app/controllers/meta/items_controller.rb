module Meta
  class ItemsController < BaseController

    load_and_authorize_resource
    include ErrorHandling
    include DcHelper
    include Sorting
    layout 'admin'

    before_action :collections_for_select, only: [ :new, :copy, :edit ]

    def index

      set_search_options

      if current_admin.super?
        if params[:search]
          search = Item.search do
            # todo repo and collection limits
            with :dpla, params[:dpla] unless params[:dpla].empty?
            with :public, params[:public] unless params[:public].empty?
            fulltext params[:keyword]
          end
          @items = search.results
        else
          @items = Item
              .order(sort_column + ' ' + sort_direction)
              .page(params[:page])
        end
      else
        if params[:search]
          search = Item.search do
            # todo limit by repos and collections based on Admin relationships
            with :dpla, params[:dpla] unless params[:dpla].empty?
            with :public, params[:public] unless params[:public].empty?
            fulltext params[:keyword]
          end
          @items = search.results
        else
          collection_ids = current_admin.collection_ids || []
          collection_ids += current_admin.repositories.map { |r| r.collection_ids }
          @items = Item
                       .includes(:collection)
                       .where(collection: collection_ids.flatten)
                       .order(sort_column + ' ' + sort_direction)
                       .page(params[:page])
        end

      end

      @items

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

    def set_search_options
      @search_options = {}
      @search_options[:collections] = Collection.all
      @search_options[:repositories] = Repository.all
      @search_options[:public] = [['Public or Not Public', ''],['Public', '1'],['Not Public', '0']]
      @search_options[:dpla] = [['Yes or No', ''],['Yes', '1'],['No', '0']]
    end
  end
end
