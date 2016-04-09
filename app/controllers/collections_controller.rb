class CollectionsController < ApplicationController
  include ErrorHandling
  include DcHelper
  include Sorting

  load_and_authorize_resource

  before_action :set_data, only: [:new, :edit]

  def index

    set_filter_options

    if current_user.super?
      @collections = Collection.index_query(params)
                               .order(sort_column + ' ' + sort_direction)
                               .page(params[:page])
    else
      @collections = Collection.index_query(params)
                               .where(id: user_collection_ids)
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
        format.html { redirect_to collection_path(@collection), notice: 'Collection item was successfully created.' }
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
      redirect_to collection_path(@collection), notice: 'Collection updated'
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
        :dc_identifier,
        :dc_right,
        :dc_relation,
        :dc_format,
        :dc_date,
        :dcterms_is_part_of,
        :dcterms_contributor,
        :dcterms_creator,
        :dcterms_description,
        :dcterms_extent,
        :dcterms_medium,
        :dcterms_identifier,
        :dcterms_language,
        :dcterms_spatial,
        :dcterms_publisher,
        :dcterms_access_right,
        :dcterms_rights_holder,
        :dcterms_subject,
        :dcterms_temporal,
        :dcterms_title,
        :dcterms_type,
        :dcterms_is_shown_at,
        :dcterms_provenance,
        :dcterms_license,
        :subject_ids => [],
        :other_repositories => []
    )
  end

  def set_filter_options
    @search_options = {}
    @search_options[:public] = [['Public or Not Public', ''],['Public', '1'],['Not Public', '0']]
    if current_user.super?
      @search_options[:repositories] = Repository.all
    elsif current_user.basic?
      @search_options[:repositories] = Repository.where(id: current_user.repository_ids)
    end
  end

    def user_collection_ids
      collection_ids = current_user.collection_ids || []
      collection_ids += current_user.repositories.map { |r| r.collection_ids }
      collection_ids.flatten
    end
end

