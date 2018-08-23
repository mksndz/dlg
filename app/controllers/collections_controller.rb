class CollectionsController < RecordController

  load_and_authorize_resource

  include Blacklight::SearchContext
  include Blacklight::SearchHelper
  include ErrorHandling
  include MetadataHelper
  include Sorting
  include Filterable

  before_action :set_data, only: [:index, :new, :create, :edit, :update]

  def index

    session[:search] = {}

    set_filter_options [:repository, :public]

    collection_query = Collection.index_query(params)
                         .order(sort_column + ' ' + sort_direction)
                         .page(params[:page])
                         .per(params[:per_page])
                         .includes(:repository)

    if params[:portal_id]
      portals_filter = params[:portal_id].reject(&:empty?)

      unless portals_filter.empty?
        collection_query = collection_query
                             .includes(:portals)
                             .joins(:portals)
                             .where(portals: { id: portals_filter })
      end

    end

    @collections = if current_user.super? || current_user.viewer?
                     collection_query
                   else
                     collection_query.where(id: user_collection_ids)
                   end

    respond_to do |format|
      format.html { render :index }
      format.json
    end

  end

  def show
  end

  def new
    @collection = Collection.new
  end

  def create

    @collection = Collection.new collection_params

    respond_to do |format|
      if @collection.save
        format.html { redirect_to collection_path(@collection), notice: I18n.t('meta.defaults.messages.success.created', entity: 'Collection') }
      else
        format.html { render :new }
      end
    end
  end

  def edit
    setup_next_and_previous_documents
  end

  def update
    if @collection.update collection_params
      redirect_to collection_path(@collection), notice: I18n.t('meta.defaults.messages.success.updated', entity: ('Collection'))
    else
      render :edit, alert: I18n.t('meta.defaults.messages.errors.not_updated', entity: 'Collection')
    end
  rescue PortalError => e
    @collection.errors.add :portals, e.message
    render :edit, alert: I18n.t('meta.defaults.messages.errors.not_updated', entity: 'Repository')
  end

  def destroy
    @collection.destroy
    redirect_to collections_path, notice: 'Collection destroyed.'
  end

  private

  def set_data
    @data = {}
    @data[:subjects] = Subject.all.order(:name)
    @data[:time_periods] = TimePeriod.all.order(:name)
    @data[:repositories] = Repository.all.order(:title)
    @data[:holding_institutions] = HoldingInstitution.all.order(:display_name)
    @data[:portals] = portals_for_form
  end

  def portals_for_form
    if @collection && @collection.persisted?
      @collection.repository.portals
    else
      Portal.all.order(:name)
    end
  end

  def collection_params
    prepare_params(
      params.require(:collection).permit(
        :repository_id,
        :slug,
        :public,
        :display_title,
        :short_description,
        :date_range,
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
        :edm_is_shown_at,
        :edm_is_shown_by,
        :dcterms_provenance,
        :dcterms_license,
        :dlg_local_right,
        :dcterms_bibliographic_citation,
        :dlg_subject_personal,
        :partner_homepage_url,
        :homepage_text,
        dc_right: [],
        dcterms_type: [],
        subject_ids: [],
        time_period_ids: [],
        other_repositories: [],
        portal_ids: []
      )
    )

  end

  def start_new_search_session?
    action_name == 'index'
  end

end

