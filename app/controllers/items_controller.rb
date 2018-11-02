# Handles CRUD for Items
# TODO: Factor out de facto index method for deleted items (ItemVersion)
# TODO: Factor out into Filterable the Portal filtering behavior
class ItemsController < RecordController

  load_and_authorize_resource

  include Blacklight::SearchContext
  include Blacklight::SearchHelper
  include ErrorHandling
  include MetadataHelper
  include Sorting
  include Filterable

  before_action :set_data, only: %i[index new create edit update copy]

  def index

    session[:search] = {}

    set_filter_options %i[repository collection public valid_item]

    item_query = Item.index_query(params)
                     .order(sort_column + ' ' + sort_direction)
                     .includes(:collection)

    if params[:portal_id]
      portals_filter = params[:portal_id].reject(&:empty?)

      unless portals_filter.empty?
        item_query = item_query.includes(:portals)
                               .joins(:portals)
                               .where(portals: { id: portals_filter })
      end
    end

    unless current_user.super? || current_user.viewer?
      item_query = item_query.where(collection: user_collection_ids)
    end

    @items = item_query

    respond_to do |format|
      format.xml { send_data @items.to_xml }
      format.tsv { render :item }
      format.html do
        @items = @items.page(params[:page])
                       .per(params[:per_page])
      end
      # format.json { send_data @items.as_json }
    end

  end

  def show; end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new item_params
    if @item.save
      redirect_to item_path(@item), notice: I18n.t('meta.defaults.messages.success.created', entity: 'Item')
    else
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
    ids = if params[:entities].is_a? String
            params[:entities].split(',')
          else
            params[:entities]
          end
    @items = Item.where id: ids
    respond_to do |format|
      format.xml { render xml: @items }
    end
  end

  def fulltext; end

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
    @data[:holding_institutions] = HoldingInstitution.all.order(:authorized_name)
    @data[:collections] = Collection.all.order(:display_title)
    @data[:portals] = portals_for_form
  end

  def portals_for_form
    if @item && @item.persisted?
      @item.collection.portals
    else
      Portal.all.order(:name)
    end
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
        :dc_relation,
        :dc_format,
        :dc_date,
        :dc_right,
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
        :edm_is_shown_at,
        :edm_is_shown_by,
        :dcterms_bibliographic_citation,
        :dlg_local_right,
        :dlg_subject_personal,
        :fulltext,
        holding_institution_ids: [],
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
