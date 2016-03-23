module Meta
  class CollectionsController < BaseController

    load_and_authorize_resource
    include ErrorHandling
    include DcHelper
    include Sorting
    layout 'admin'

    before_action :set_data, only: [:new, :edit]

    def index
      @repositories = Repository.all.order(:title)

      if current_user.admin?
        if params[:repository_id]
          @collections = Collection
                             .where(repository_id: params[:repository_id])
                             .order(sort_column + ' ' + sort_direction)
                             .page(params[:page])
        else
          @collections = Collection
                             .order(sort_column + ' ' + sort_direction)
                             .page(params[:page])
        end
      else
        collection_ids = current_user.collection_ids
        current_user.repositories.each { |r| collection_ids << r.collection_ids }
        @collections = Collection
                           .where(id: collection_ids.flatten)
                           .order(sort_column + ' ' + sort_direction)
                           .page(params[:page])
      end

    end

    def show
    end

    def new
      @collection = Collection.new
      repositories_for_select
    end

    def create

      @collection = Collection.new(split_dc_params(collection_params))

      respond_to do |format|
        if @collection.save
          format.html { redirect_to admin_collection_path(@collection), notice: 'Collection item was successfully created.' }
        else
          repositories_for_select
          format.html { render :new }
        end
      end
    end

    def edit
      repositories_for_select
    end

    def update

      new_params = split_dc_params(collection_params)

      if @collection.update new_params
        redirect_to admin_collection_path(@collection), notice: 'Collection updated'
      else
        repositories_for_select
        render :edit, alert: 'Error creating collection'
      end
    end

    def destroy
      @collection.destroy
      redirect_to admin_collections_path, notice: 'Collection destroyed.'
    end

    private

    def set_data
      @data = {}
      @data[:subjects] = Subject.all.order(:name)
      @data[:repositories] = Repository.all.order(:title)
    end

    def repositories_for_select
      @repositories = Repository.all.order(:title)
    end

    def collection_params
      params.require(:collection).permit(
          :repository_id,
          :slug,
          :in_georgia,
          :remote,
          :public,
          :display_title,
          :short_description,
          :teaser,
          :color,
          :date_range,
          :dc_title,
          :dc_format,
          :dc_publisher,
          :dc_identifier,
          :dc_right,
          :dc_contributor,
          :dc_coverage_spatial,
          :dc_coverage_temporal,
          :dc_date,
          :dc_source,
          :dc_subject,
          :dc_type,
          :dc_description,
          :dc_creator,
          :dc_language,
          :dc_relation,
          :subject_ids => [],
          :other_repositories => []
      )
    end
  end
end

