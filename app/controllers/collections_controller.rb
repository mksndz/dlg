class CollectionsController < RecordController

  load_and_authorize_resource

  include Blacklight::SearchContext
  include Blacklight::SearchHelper
  include ErrorHandling
  include MetadataHelper
  include Sorting
  include Filterable

  before_action :set_data, only: [:new, :edit]

  def index

    session[:search] = {}

    set_filter_options [:repository, :public]

    if current_user.super?
      @collections = Collection.index_query(params)
                               .order(sort_column + ' ' + sort_direction)
                               .page(params[:page])
                               .per(params[:per_page])
                               .includes(:repository)
    else
      @collections = Collection.index_query(params)
                               .where(id: user_collection_ids)
                               .order(sort_column + ' ' + sort_direction)
                               .page(params[:page])
                               .per(params[:per_page])
                               .includes(:repository)
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
        set_data
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
      set_data
      render :edit, alert: I18n.t('meta.defaults.messages.errors.not_updated', entity: 'Collection')
    end
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
    @data[:portals] = Portal.all.order(:name)
  end

  def collection_params
    prepare_params(
        params.require(:collection).permit(
            :repository_id,
            :slug,
            :in_georgia,
            :remote,
            :public,
            :display_title,
            :short_description,
            :color,
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
            :dcterms_access_right,
            :dcterms_rights_holder,
            :dcterms_subject,
            :dcterms_temporal,
            :dcterms_title,
            :dcterms_is_shown_at,
            :dcterms_provenance,
            :dcterms_license,
            :dlg_local_right,
            :dcterms_bibliographic_citation,
            :dcterms_type => [],
            :subject_ids => [],
            :time_period_ids => [],
            :other_repositories => [],
            :portal_ids => []
        )
    )

  end

  def start_new_search_session?
    action_name == 'index'
  end

end

