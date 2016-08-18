class RepositoriesController < ApplicationController

  load_and_authorize_resource
  include ErrorHandling
  include Sorting

  def index

    if current_user.super?
      @repositories = Repository
                          .order(sort_column + ' ' + sort_direction)
                          .page(params[:page])
                          .per(params[:per_page])
    else
      @repositories = Repository
                          .where(id: current_user.repository_ids)
                          .order(sort_column + ' ' + sort_direction)
                          .page(params[:page])
                          .per(params[:per_page])
    end

  end

  def show
  end

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

  def edit
  end

  def update
    if @repository.update(repository_params)
      redirect_to repository_path(@repository), notice: I18n.t('meta.defaults.messages.success.updated', entity: 'Repository')
    else
      render :edit, alert: I18n.t('meta.defaults.messages.errors.not_updated', entity: 'Repository')
    end
  end

  def destroy
    @repository.destroy
    redirect_to repositories_path, notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'Repository')
  end

  private

  def repository_params
    params.require(:repository).permit(
        :slug,
        :title,
        :teaser,
        :short_description,
        :description,
        :coordinates,
        :color,
        :public,
        :in_georgia,
        :homepage_url,
        :directions_url,
        :address,
        :strengths,
        :contact
    )
  end

end
