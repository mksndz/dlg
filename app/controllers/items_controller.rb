#
# Handles CRUD for Items
# TODO: Factor out de facto index method for deleted items (ItemVersion)
# TODO: Factor out into Filterable the Portal filtering behavior
#
class ItemsController < RecordController

  load_and_authorize_resource

  include Blacklight::SearchContext
  include Blacklight::SearchHelper
  include ErrorHandling
  include MetadataHelper
  include Sorting
  include Filterable

  before_action :set_data, only: [:new, :copy, :edit]

  def index

    session[:search] = {}

    set_filter_options [:repository, :collection, :public, :valid_item]

    item_query = Item.index_query(params)
                     .order(sort_column + ' ' + sort_direction)
                     .includes(:collection)

    if params[:portal_id]
      portals_filter = params[:portal_id].reject(&:empty?)

      unless portals_filter.empty?
        item_query = item_query
                       .includes(:portals)
                       .joins(:portals)
                       .where(portals: { id: portals_filter })
      end
    end

    unless current_user.super?
      item_query = item_query.where(collection: user_collection_ids)
    end

    @items = item_query

    respond_to do |format|
      format.xml { send_data @items.to_xml }
      format.html do
        @items = @items
                   .page(params[:page])
                   .per(params[:per_page])
      end
      # format.json { send_data @items.as_json }
    end

  end

  def show
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new item_params
    if @item.save
      redirect_to item_path(@item), notice: I18n.t('meta.defaults.messages.success.created', entity: 'Item')
    else
      set_data
      render :new, alert: I18n.t('meta.defaults.messages.errors.not_created', entity: 'Item')
    end
  end

  def copy
    @item = Item.new(@item.attributes.except(:id))
    render :edit
  end

  def edit
    setup_next_and_previous_documents
  end

  def update
    if @item.update item_params
      redirect_to item_path(@item), notice: I18n.t('meta.defaults.messages.success.updated', entity: 'Item')
    else
      set_data
      render :edit, alert: I18n.t('meta.defaults.messages.errors.not_updated', entity: 'Item')
    end
  end

  def destroy
    @item.destroy
    redirect_to items_path, notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'Item')
  end

  def multiple_destroy
    Item.destroy(multiple_action_params[:entities].split(','))
    Sunspot.commit
    respond_to do |format|
      format.json { render json: {}, status: :ok }
    end
  end

  def xml
    @items = Item.where id: multiple_action_params[:entities].split(',')
    respond_to do |format|
      format.xml { render xml: @items }
    end
  end

  def deleted

    set_filter_options [:user]

    @item_versions = ItemVersion
                       .index_query(params)
                       .where(item_type: 'Item', event: 'destroy')
                       .order(sort_column('item_versions') + ' ' + sort_direction)
                       .page(params[:page])
                       .per(params[:per_page])
  end

  private

  def set_data
    @data = {}
    @data[:collections] = Collection.all.order(:display_title)
    @data[:portals] = Portal.all.order(:name)
  end

  def item_params
    prepare_params(
      params.require(:item).permit(
        :collection_id,
        :slug,
        :dpla,
        :public,
        :local,
        :date_range,
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
        :dcterms_rights_holder,
        :dcterms_subject,
        :dcterms_temporal,
        :dcterms_title,
        :dcterms_is_shown_at,
        :dcterms_provenance,
        :dcterms_bibliographic_citation,
        :dlg_local_right,
        :dlg_subject_personal,
        dcterms_type: [],
        other_collections: [],
        portal_ids: []
      )
    )
  end

  def multiple_action_params
    params.permit(:entities, :format)
  end

  def start_new_search_session?
    action_name == 'index'
  end

end
