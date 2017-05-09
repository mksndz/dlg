class BatchItemsController < RecordController

  load_and_authorize_resource
  include ErrorHandling
  include Sorting
  include MetadataHelper
  before_action :set_batch
  before_action :set_data, only: [:new, :edit]
  before_action :check_if_committed, except: [:index, :show]

  rescue_from BatchCommittedError do
    redirect_to({ action: 'index' }, alert: I18n.t('meta.batch.messages.errors.batch_already_committed'))
  end

  # GET /batch_items
  # GET /batch_items.json
  def index
    @batch_items = BatchItem.where(batch_id: @batch.id)
                       .page(params[:page])
                       .per(params[:per_page])
  end

  # GET /batch_items/1
  # GET /batch_items/1.json
  def show
  end

  # GET /batch_items/new
  def new
    @batch_item = BatchItem.new
    @batch_item.batch = @batch
  end

  # GET /batch_items/1/edit
  def edit
    set_next_and_previous
  end

  # POST /batch_items
  # POST /batch_items.json
  def create
    @batch_item = BatchItem.new batch_item_params
    @batch_item.batch = @batch

    respond_to do |format|
      if @batch_item.save
        format.html { redirect_to batch_batch_item_path(@batch, @batch_item), notice: I18n.t('meta.defaults.messages.success.created', entity: 'Batch Item') }
        format.json { render :show, status: :created, location: @batch_item }
      else
        set_data
        format.html { render :new }
        format.json { render json: @batch_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /batch_items/1
  # PATCH/PUT /batch_items/1.json
  def update
    respond_to do |format|
      if @batch_item.update batch_item_params
        format.html { redirect_to after_save_destination, notice: I18n.t('meta.defaults.messages.success.updated', entity: 'Batch Item') }
        format.json { render :show, status: :ok, location: @batch_item }
      else
        set_data
        set_next_and_previous
        format.html { render :edit }
        format.json { render json: @batch_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /batch_items/1
  # DELETE /batch_items/1.json
  def destroy
    @batch_item.destroy
    respond_to do |format|
      format.html { redirect_to batch_batch_items_path(@batch), notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'Batch Item') }
      format.json { head :no_content }
    end
  end

  # POST /bulk_add
  def bulk_add

    ids = params[:ids].split(',')

    @batch_items = []
    @errors = []

    ids.each do |id|
      begin
        i = Item.find id
        batch_item = i.to_batch_item
        batch_item.batch = @batch
        batch_item.save(validate: false)
        @batch_items << batch_item
      rescue ActiveRecord::RecordNotFound => ar_e
        @errors << "Record with ID #{id} could not be found to add to Batch."
      rescue StandardError => e
        @errors << "Item #{i.record_id} could not be added to Batch: #{e}"
      end
    end

    respond_to do |format|
      format.js { render layout: false }
    end

  end

  private

  def set_batch
    @batch = Batch.where(id: params[:batch_id]).first
  end

  def set_next_and_previous
    @previous = @batch_item.previous
    @next = @batch_item.next
  end

  def set_data
    @data = {}
    @data[:collections] = Collection.all.order(:display_title)
    @data[:portals] = Portal.all.order(:name)
  end

  def batch_item_params
    prepare_params(
        params.require(:batch_item).permit(
            :collection_id,
            :batch_id,
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
            :dcterms_type => [],
            :other_collections  => [],
            :portal_ids => []
        )
    )
  end

  def check_if_committed
    raise BatchCommittedError.new if @batch.committed?
  end

  def after_save_destination
    return edit_batch_batch_item_path(@batch, @batch_item.next) if params.has_key? :next
    return edit_batch_batch_item_path(@batch, @batch_item.previous) if params.has_key? :previous
    batch_batch_item_path(@batch, @batch_item)
  end

end