class BatchesController < ApplicationController

  load_and_authorize_resource

  include ErrorHandling
  include Sorting
  include Filterable
  include UserHelper

  before_action :check_if_committed, only: [:edit, :update, :destroy, :commit]

  rescue_from BatchCommittedError do
    redirect_to({ action: 'index' }, alert: I18n.t('meta.batch.messages.errors.batch_already_committed'))
  end

  # GET /batches
  # GET /batches.json
  def index

    set_filter_options [:user, :status]

    @user = User.find(params[:user_id]) unless !params[:user_id] or params[:user_id].empty?

    bq = Batch.index_query(params)
              .order(sort_column + ' ' + sort_direction)
              .page(params[:page])
              .per(params[:per_page])

    unless current_user.super?
      if current_user.coordinator?
        bq = bq.where(user: users_managed_by_and(current_user))
      elsif current_user.basic?
        bq = bq.where(user: current_user)
      end
    end

    if params[:status] == 'committed'
      @batches = bq.committed
    elsif params[:status] == 'pending'
      @batches = bq.pending
    else
      @batches = bq
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
        format.html { redirect_to @batch, notice: I18n.t('meta.defaults.messages.success.created', entity: 'Batch') }
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
        format.html { redirect_to @batch, notice: I18n.t('meta.defaults.messages.success.updated') }
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
      format.html { redirect_to batches_url, notice: I18n.t('meta.defaults.messages.success.destroyed')}
      format.json { head :no_content }
    end
  end

  def commit_form
    if @batch.batch_items.count > 0
      render :commit_form
    else
      redirect_to @batch, alert: I18n.t('meta.batch.labels.empty_batch_commit')
    end
  end

  def commit
    respond_to do |format|
      if @batch.batch_items.count == 0
        format.html { redirect_to @batch, alert: I18n.t('meta.batch.labels.empty_batch_commit') }
        format.json { head :no_content }
      else
        @batch.queued_for_commit_at = Time.now
        @batch.save
        @batch.delay.commit
        format.html { redirect_to @batch, notice: I18n.t('meta.batch.messages.success.committed') }
        format.json { head :no_content }
      end
    end
  end

  def results
  end

  def import
  end

  def recreate
    recreated_batch = @batch.recreate
    recreated_batch.user = current_user
    respond_to do |format|
      if recreated_batch.save
        format.html { redirect_to recreated_batch, notice: I18n.t('meta.batch.messages.success.recreated')}
      else
        format.html { redirect_to @batch, notice: I18n.t('meta.batch.messages.errors.not_recreated') }
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