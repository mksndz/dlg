# Controller action for Repository functionality, duh
class RepositoriesController < ApplicationController
  load_and_authorize_resource
  include ErrorHandling
  include Sorting
  include Filterable
  before_action :set_data, only: %i[index new create edit update]

  def index
    repository_query = Repository.index_query(params)
                                 .order(sort_column + ' ' + sort_direction)
                                 .page(params[:page])
                                 .per(params[:per_page])

    if params[:portal_id]
      portals_filter = params[:portal_id].reject(&:empty?)
      unless portals_filter.empty?
        repository_query = repository_query
                           .includes(:portals)
                           .joins(:portals)
                           .where(portals: { id: portals_filter })
      end
    end
    repository_query = repository_query.where(id: current_user.repository_ids) unless current_user.super? || current_user.viewer?
    @repositories = repository_query
  end

  def show; end

  def new
    @repository = Repository.new
  end

  def create
    @repository = Repository.new repository_params
    if @repository.save
      redirect_to repository_path(@repository), notice: I18n.t('meta.defaults.messages.success.created', entity: 'Repository')
    else
      render :new, alert: I18n.t('meta.defaults.messages.errors.not_created', entity: 'Repository')
    end
  end

  def edit; end

  def update
    if @repository.update(repository_params)
      redirect_to repository_path(@repository), notice: I18n.t('meta.defaults.messages.success.updated', entity: 'Repository')
    else
      render :edit, alert: I18n.t('meta.defaults.messages.errors.not_updated', entity: 'Repository')
    end
  rescue PortalError => e
    @repository.errors.add :portals, e.message
    render :edit, alert: I18n.t('meta.defaults.messages.errors.not_updated', entity: 'Repository')
  end

  def destroy
    @repository.destroy
    redirect_to repositories_path, notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'Repository')
  end

  private

  def set_data
    @data = {}
    @data[:portals] = Portal.all.order(:name)
  end

  def repository_params
    params
      .require(:repository)
      .permit(:slug, :title, :notes, :public, portal_ids: [])
  end

end
