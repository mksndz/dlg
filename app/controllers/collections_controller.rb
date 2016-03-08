class CollectionsController < ApplicationController

  load_and_authorize_resource
  include ErrorHandling
  include DcHelper
  include Sorting
  layout 'admin'

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
                   .where(id: collection_ids)
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
    @collection = Collection.new collection_params
    if @collection.save
      redirect_to @collection, notice: 'Collection created'
    else
      repositories_for_select
      render :new, alert: 'Error creating collection'
    end

  end

  def edit
    repositories_for_select
  end

  def update
    if @collection.update(collection_params)
      redirect_to @collection, notice: 'Collection updated'
    else
      repositories_for_select
      render :edit, alert: 'Error creating collection'
    end
  end

  def destroy
    @collection.destroy
    redirect_to collections_path, notice: 'Collection destroyed.'
  end

  private
    def repositories_for_select
      @repositories = Repository.all.order(:title)
    end

    def collection_params
      prepare_params
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
          :other_repositories => [],
          :subject_ids        => [],
          :dc_title           => [],
          :dc_format          => [],
          :dc_publisher       => [],
          :dc_identifier      => [],
          :dc_right          => [],
          :dc_contributor     => [],
          :dc_coverage_spatial      => [],
          :dc_coverage_temporal      => [],
          :dc_date            => [],
          :dc_source          => [],
          :dc_subject         => [],
          :dc_type            => [],
          :dc_description     => [],
          :dc_creator         => [],
          :dc_language        => [],
          :dc_relation        => []
      )
    end

    def prepare_params
      array_fields = dc_fields + [:other_repositories] #ugly
      array_fields.each do |f|
        params[:collection][f].reject! { |v| v == '' } if params[:collection][f]
      end
    end
end

