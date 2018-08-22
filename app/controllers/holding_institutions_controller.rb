class HoldingInstitutionsController < ApplicationController

  load_and_authorize_resource
  include HoldingInstitutionsHelper
  include ErrorHandling
  include Sorting

  before_action :set_data, only: [:index, :new, :create, :edit, :update]

  # GET /holding_institutions
  def index
    @holding_institutions = HoldingInstitution
                              .order(sort_column + ' ' + sort_direction)
                              .page(params[:page])
  end

  # GET /holding_institutions/1
  def show; end

  # GET /holding_institutions/new
  def new
    @holding_institution = HoldingInstitution.new
  end

  # GET /holding_institutions/1/edit
  def edit; end

  # POST /holding_institutions
  def create
    @holding_institution = HoldingInstitution.new(holding_institution_params)
    if @holding_institution.save
      redirect_to holding_institution_path(@holding_institution), notice: I18n.t('meta.defaults.messages.success.created', entity: 'Holding Institution')
    else
      render :new
    end
  end

  # PATCH/PUT /holding_institutions/1
  def update
    if @holding_institution.update(holding_institution_params)
      redirect_to holding_institution_path(@holding_institution), notice: I18n.t('meta.defaults.messages.success.updated', entity: 'Holding Institution')
    else
      render :edit
    end
  end

  # DELETE /holding_institutions/1
  def destroy
    @holding_institution.destroy
    redirect_to holding_institutions_url, notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'Holding Institution')
  end

  private
  def holding_institution_params
    params.require(:holding_institution).permit()
  end
  def set_data
    @data = {}
    @data[:repositories] = Repository.all.order(:title)
  end
end

