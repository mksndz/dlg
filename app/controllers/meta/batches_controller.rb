module Meta
  class BatchesController < BaseController

    load_and_authorize_resource
    before_action :check_if_committed, only: [:edit, :update, :destroy]
    include ErrorHandling
    include Sorting
    layout 'admin'

    # GET /batches
    # GET /batches.json
    def index

      @admins = User.all # all admins with batches?

      if params[:admin_id]
        @admin = User.find(params[:admin_id])
        @batches = Batch
                       .where(admin_id: params[:admin_id])
                       .order(sort_column + ' ' + sort_direction)
                       .page(params[:page])
      else
        @batches = Batch
                       .order(sort_column + ' ' + sort_direction)
                       .page(params[:page])
      end

    end

    # GET /batches/1
    # GET /batches/1.json
    def show
    end

    # GET /batches/new
    def new
      @batch = Batch.new
    end

    # GET /batches/1/edit
    def edit
    end

    # POST /batches
    # POST /batches.json
    def create
      @batch = Batch.new(batch_params)

      set_admin

      respond_to do |format|
        if @batch.save
          format.html { redirect_to @batch, notice: 'Batch was successfully created.' }
          format.json { render :show, status: :created, location: @batch }
        else
          format.html { render :new }
          format.json { render json: @batch.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /batches/1
    # PATCH/PUT /batches/1.json
    def update

      set_admin

      respond_to do |format|
        if @batch.update(batch_params)
          format.html { redirect_to @batch, notice: 'Batch was successfully updated.' }
          format.json { render :show, status: :ok, location: @batch }
        else
          format.html { render :edit }
          format.json { render json: @batch.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /batches/1
    # DELETE /batches/1.json
    def destroy
      @batch.destroy
      respond_to do |format|
        format.html { redirect_to meta_batches_url, notice: 'Batch was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    def set_admin
      @batch.admin = current_admin
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def batch_params
      params.require(:batch).permit(
          :name,
          :notes,
          :admin_id
      )
    end

    def check_if_committed
      if @batch.committed?
        # TODO raise BatchWorksHelper::BatchCommittedException
      end
    end

  end
end
