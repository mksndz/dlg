class TimePeriodsController < ApplicationController

  load_and_authorize_resource
  include ErrorHandling
  include Sorting

  # GET /time_periods
  # GET /time_periods.json
  def index
    @time_periods = TimePeriod.all
  end

  # GET /time_periods/1
  # GET /time_periods/1.json
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
  # POST /time_periods.json
  def create
    @time_period = TimePeriod.new(time_period_params)

    respond_to do |format|
      if @time_period.save
        format.html { redirect_to @time_period, notice: 'Time period was successfully created.' }
        format.json { render :show, status: :created, location: @time_period }
      else
        format.html { render :new }
        format.json { render json: @time_period.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /time_periods/1
  # PATCH/PUT /time_periods/1.json
  def update
    respond_to do |format|
      if @time_period.update(time_period_params)
        format.html { redirect_to @time_period, notice: 'Time period was successfully updated.' }
        format.json { render :show, status: :ok, location: @time_period }
      else
        format.html { render :edit }
        format.json { render json: @time_period.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /time_periods/1
  # DELETE /time_periods/1.json
  def destroy
    @time_period.destroy
    respond_to do |format|
      format.html { redirect_to time_periods_url, notice: 'Time period was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def time_period_params
      params.require(:time_period).permit(:name, :start, :end)
    end
end
