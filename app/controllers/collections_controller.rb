class CollectionsController < ApplicationController
  include DcHelper

  helper_method :sort_column, :sort_direction

  layout 'admin'

  def index

    @repositories = Repository.all.order(:title)

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

  end

  def show

    find_collection

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

    find_collection
    repositories_for_select

  end

  def update

    if find_collection.update(collection_params)
      redirect_to @collection, notice: 'Collection updated'
    else
      repositories_for_select
      render :edit, alert: 'Error creating collection'
    end

  end

  def destroy

    if find_collection.destroy
      redirect_to collections_path, notice: 'Collection destroyed.'
    else
      redirect_to collections_path, alert: 'Collection could not be destroyed.'
    end

  end

  private

  def find_collection
    @collection = Collection.find(params[:id])
  end

  def repositories_for_select
    @repositories_for_select = Repository.all.collect { |r| [ "#{r.title} (#{r.slug}}", r.id ] }
  end

  def collection_params
    remove_blank_multi_values
    params.require(:collection).permit(
        :repository_id,
        :slug,
        :in_georgia,
        :remote,
        :display_title,
        :short_description,
        :teaser,
        :color,
        :other_repositories,
        :date_range,
        :dc_title       => [],
        :dc_format      => [],
        :dc_publisher   => [],
        :dc_identifier  => [],
        :dc_rights      => [],
        :dc_contributor => [],
        :dc_coverage_s  => [],
        :dc_coverage_t  => [],
        :dc_date        => [],
        :dc_source      => [],
        :dc_subject     => [],
        :dc_type        => [],
        :dc_description => [],
        :dc_creator     => [],
        :dc_language    => [],
        :dc_relation    => []
    )
  end

  def remove_blank_multi_values
    dc_fields.each do |f|
      params[:collection][f].reject! { |v| v == '' } if params[:collection][f]
    end
  end

  def sort_column
    Collection.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end

