class BatchItemsController < ApplicationController
  before_action :set_batch_item, only: [:show, :edit, :update, :destroy]
  before_action :set_batch

  layout 'admin'

  # GET /batch_items
  # GET /batch_items.json
  def index
    @batch_items = BatchItem.where(batch: @batch)
  end

  # GET /batch_items/1
  # GET /batch_items/1.json
  def show
  end

  # GET /batch_items/new
  def new
    @batch_item = BatchItem.new
    render 'items/new'
  end

  # GET /batch_items/1/edit
  def edit
    render 'items/edit'
  end

  # POST /batch_items
  # POST /batch_items.json
  def create
    @batch_item = BatchItem.new(batch_item_params)
    @batch_item.batch = @batch

    respond_to do |format|
      if @batch_item.save
        format.html { redirect_to @batch_item, notice: 'Batch item was successfully created.' }
        format.json { render :show, status: :created, location: @batch_item }
      else
        format.html { render :new }
        format.json { render json: @batch_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /batch_items/1
  # PATCH/PUT /batch_items/1.json
  def update
    respond_to do |format|
      if @batch_item.update(batch_item_params)
        format.html { redirect_to @batch_item, notice: 'Batch item was successfully updated.' }
        format.json { render :show, status: :ok, location: @batch_item }
      else
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
      format.html { redirect_to batch_items_url, notice: 'Batch item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_batch_item
      @batch_item = BatchItem.find(params[:id])
    end

    def set_batch
      @batch = Batch.find(params[:batch_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def batch_item_params
      params.require(:batch_item).permit(
          :collection_id,
          :slug,
          :dpla,
          :public,
          :other_collections,
          :date_range,
          :dc_title       => [],
          :dc_format      => [],
          :dc_publisher   => [],
          :dc_identifier  => [],
          :dc_rights      => [],
          :dc_contributor => [],
          :dc_coverage_s  => [],
          :dc_coverage_t  => [],
          :dc_date        => [],
          :dc_source      => [],
          :dc_subject     => [],
          :dc_type        => [],
          :dc_description => [],
          :dc_creator     => [],
          :dc_language    => [],
          :dc_relation    => []
      )
    end
end
