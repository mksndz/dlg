class RepositoriesController < ApplicationController

  load_and_authorize_resource
  helper_method :sort_direction, :sort_column
  layout 'admin'

  def index
    @repositories = Repository.page(params[:page])
  end

  def show
  end

  def new
    @repository = Repository.new
  end

  def create
    @repository = Repository.new repository_params
    if @repository.save
      redirect_to @repository, notice: 'Repository created'
    else
      render :new, alert: 'Error creating repository'
    end
  end

  def edit
  end

  def update
    if @repository.update(repository_params)
      redirect_to @repository, notice: 'Repository updated'
    else
      render :edit, alert: 'Error creating repository'
    end
  end

  def destroy
    @repository.destroy
    redirect_to repositories_path, notice: 'Repository destroyed.'
  end

  private
    def repository_params
      params.require(:repository).permit(
        :slug,
        :title,
        :teaser,
        :short_description,
        :description,
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


    def sort_column
      Repository.column_names.include?(params[:sort]) ? params[:sort] : 'id'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end
