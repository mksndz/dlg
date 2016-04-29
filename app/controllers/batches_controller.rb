class BatchesController < ApplicationController

  load_and_authorize_resource
  include ErrorHandling
  include Sorting

  before_action :check_if_committed, only: [:edit, :update, :destroy, :commit]

  rescue_from BatchCommittedError do
    redirect_to({ action: 'committed' }, alert: 'Batch has already been committed')
  end

  # GET /batches
  # GET /batches.json
  def index

    @users = User.all # all admins with batches?

    if params[:user_id]
      @user = User.find(params[:user_id])
      @batches = Batch.pending
                     .where(user_id: params[:user_id])
                     .order(sort_column + ' ' + sort_direction)
                     .page(params[:page])
                     .per(params[:per_page])
    else
      @batches = Batch.pending
                     .order(sort_column + ' ' + sort_direction)
                     .page(params[:page])
                     .per(params[:per_page])
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

    set_user

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

    set_user

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
      format.html { redirect_to batches_url, notice: 'Batch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def commit
    respond_to do |format|
      if @batch.committed?
        format.html { redirect_to @batch, notice: "Batch was already committed at #{@batch.committed_at}" }
        format.json { head :no_content }
      else
        @batch.commit
        format.html { redirect_to results_batch_path(@batch), notice: 'Batch was successfully committed.' }
        format.json { head :no_content }
      end
    end
  end

  def results
  end

  def committed
    @users = User.all # all admins with committed batches?
    if params[:user_id]
      @user = User.find(params[:user_id])
      @batches = Batch.committed
                     .where(user_id: params[:user_id])
                     .order(sort_column + ' ' + sort_direction)
                     .page(params[:page])
                     .per(params[:per_page])
    else
      @batches = Batch.committed
                     .order(sort_column + ' ' + sort_direction)
                     .page(params[:page])
                     .per(params[:per_page])
    end

  end

  def xml
  end

  def recreate
    recreated_batch = @batch.recreate
    recreated_batch.user = current_user
    respond_to do |format|
      if recreated_batch.save
        format.html { redirect_to recreated_batch, notice: 'Batch was successfully recreated.' }
      else
        format.html { redirect_to @batch, notice: 'Batch could not be recreated.' }
      end
    end
  end

  private

  def set_user
    @batch.user = current_user
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def batch_params
    params.require(:batch).permit(
        :name,
        :notes,
        :user_id
    )
  end

  def check_if_committed
    raise BatchCommittedError.new if @batch.committed?
  end

end