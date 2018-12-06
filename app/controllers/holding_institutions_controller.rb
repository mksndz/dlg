# actions for CRUD on Holding Institutions
class HoldingInstitutionsController < ApplicationController
  load_and_authorize_resource
  include HoldingInstitutionsHelper
  include ErrorHandling
  include Sorting

  MULTIVALUED_TEXT_FIELDS = %w[oai_urls analytics_emails].freeze

  before_action :set_data, only: %i[index new create edit update]

  rescue_from HoldingInstitutionInUseError do |exception|
    redirect_to({ action: 'index' }, alert: exception.message)
  end

  # GET /holding_institutions
  def index
    @holding_institutions =
      HoldingInstitution.index_query(params)
                        .includes(:projects)
                        .includes(repositories: [:portals])
                        .order(sort_column + ' ' + sort_direction)
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
    prepare_params(
      params
        .require(:holding_institution)
        .permit(:display_name, :short_description, :description,
                :homepage_url, :coordinates, :strengths, :authorized_name,
                :contact_information, :galileo_member, :institution_type,
                :contact_name, :contact_email, :harvest_strategy, :oai_urls,
                :ignored_collections, :analytics_emails, :subgranting,
                :grant_partnerships, :image, :remove_image, :image_cache,
                :notes, :parent_institution, :slug, repository_ids: [])
    )
  end

  def set_data
    @data = {}
    @data[:institution_types] = HOLDING_INSTITUTION_TYPES.dup.unshift('')
    @data[:repositories] = Repository.all.order(:title)
    @data[:portals] = Portal.all.order(:name)
  end

  def prepare_params(params)
    params.each do |f, v|
      if v.is_a? Array
        params[f] = v.reject(&:empty?)
        next
      end
      params[f] = v.gsub("\r\n", "\n").strip.split("\n") if MULTIVALUED_TEXT_FIELDS.include? f
    end
  end
end

