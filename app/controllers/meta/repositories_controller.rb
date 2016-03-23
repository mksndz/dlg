module Meta
  class RepositoriesController < BaseController

    load_and_authorize_resource
    include ErrorHandling
    include Sorting
    layout 'admin'

    def index
      if current_admin.super?
        @repositories = Repository
                            .order(sort_column + ' ' + sort_direction)
                            .page(params[:page])
      else
        # todo sorting?
        @repositories = current_admin.repositories.page(params[:page])
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
        redirect_to meta_repository_path(@repository), notice: 'Repository created'
      else
        render :new, alert: 'Error creating repository'
      end
    end

    def edit
    end

    def update
      if @repository.update(repository_params)
        redirect_to meta_repository_path(@repository), notice: 'Repository updated'
      else
        render :edit, alert: 'Error creating repository'
      end
    end

    def destroy
      @repository.destroy
      redirect_to meta_repositories_path, notice: 'Repository destroyed.'
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
  end
end
