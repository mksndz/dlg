module Meta
  class BatchItemsController < MetaController

    load_and_authorize_resource
    include ErrorHandling
    include Sorting
    include DcHelper
    before_action :set_batch
    before_action :collections_for_select, only: [:new, :edit]
    layout 'admin'

    # GET /batch_items
    # GET /batch_items.json
    def index
      @batch_items = BatchItem.where(batch_id: @batch.id).page(params[:page])
    end

    # GET /batch_items/1
    # GET /batch_items/1.json
    def show
    end

    # GET /batch_items/new
    def new
      @batch_item = BatchItem.new
    end

    # GET /batch_items/1/edit
    def edit
    end

    # POST /batch_items
    # POST /batch_items.json
    def create
      @batch_item = BatchItem.new(split_dc_params(batch_item_params))
      @batch_item.batch = @batch

      respond_to do |format|
        if @batch_item.save
          format.html { redirect_to meta_batch_batch_item_path(@batch, @batch_item), notice: 'Batch item was successfully created.' }
          format.json { render :show, status: :created, location: @batch_item }
        else
          collections_for_select
          format.html { render :new }
          format.json { render json: @batch_item.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /batch_items/1
    # PATCH/PUT /batch_items/1.json
    def update
      respond_to do |format|
        if @batch_item.update(split_dc_params(batch_item_params))
          format.html { redirect_to meta_batch_batch_item_path(@batch, @batch_item), notice: 'Batch item was successfully updated.' }
          format.json { render :show, status: :ok, location: @batch_item }
        else
          collections_for_select
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
        format.html { redirect_to meta_batch_batch_items_path(@batch), notice: 'Batch item was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    def xml

    end

    def create_from_xml

      # todo add csrf protection

      hash = BatchItem.create_from_xml params[:xml_text].squish

      if hash
        @batch_item = hash[:batch_item]

        collection = Collection.find_by_slug(hash[:parent_slug])

        @batch_item.batch = @batch
        @batch_item.collection = collection
      end

      throw ArgumentError unless @batch_item

      respond_to do |format|
        if @batch_item.save
          # format.html { redirect_to batch_batch_item_path(@batch, @batch_item), notice: 'Batch item was successfully updated.' }
          format.json { render :import_results, status: :ok, location: meta_batch_batch_item_path(@batch, @batch_item) }
        else
          # format.html { render :edit }
          format.json { render json: @batch_item.errors, status: :unprocessable_entity }
        end
      end

    end

    private
    def set_batch
      @batch = Batch.find(params[:batch_id])
    end

    def collections_for_select
      @collections = Collection.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def batch_item_params
      params.require(:meta_batch_item).permit(
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

end
