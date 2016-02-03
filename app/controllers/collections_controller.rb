class CollectionsController < ApplicationController

  def index

    @collections = Collection.all

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
        :dpla,
        :public,
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
        :dc_description => []
    )
  end

  def remove_blank_multi_values
    multi_fields.each do |f|
      params[:collection][f].reject! { |v| v == '' }
    end
  end

  def multi_fields
    %w(
      dc_title
      dc_format
      dc_publisher
      dc_identifier
      dc_rights
      dc_contributor
      dc_coverage_s
      dc_coverage_t
      dc_date
      dc_source
      dc_subject
      dc_type
      dc_description
    )
  end

end

