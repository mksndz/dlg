class TimePeriodsController < ApplicationController

  load_and_authorize_resource
  include ErrorHandling
  include Sorting

  # GET /time_periods
  def index
    @time_periods = TimePeriod
                    .order(sort_column + ' ' + sort_direction)
                    .page(params[:page])
  end

  # GET /time_periods/1
  def show
  end

  # GET /time_periods/new
  def new
    @time_period = TimePeriod.new
  end

  # GET /time_periods/1/edit
  def edit
  end

  # POST /time_periods
  def create
    @time_period = TimePeriod.new(time_period_params)
    if @time_period.save
      redirect_to time_period_path(@time_period), notice: I18n.t('meta.defaults.messages.success.created', entity: 'Time Period')
    else
      render :new
    end
  end

  # PATCH/PUT /time_periods/1
  def update
    if @time_period.update(time_period_params)
      redirect_to time_period_path(@time_period), notice: I18n.t('meta.defaults.messages.success.updated', entity: 'Time Period')
    else
      render :edit
    end
  end

  # DELETE /time_periods/1
  def destroy
    @time_period.destroy
    redirect_to time_periods_url, notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'Time Period')
  end

  private
  def time_period_params
    params.require(:time_period).permit(:name, :begin, :finish)
  end
end

