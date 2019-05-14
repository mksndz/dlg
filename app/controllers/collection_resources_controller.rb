# frozen_string_literal: true

class CollectionResourceController < RecordController
  authorize_resource
  decorates_finders
  # decorates_association
  include ErrorHandling
  include Sorting
  before_action :set_collection
  # before_action :set_data, only: [:new, :edit]
  # before_action :check_if_committed, except: [:index, :show]

  # GET /collection_resources
  # GET /collection_resources.json
  def index
    @collection_resources = CollectionResource
                            .order(sort_column + ' ' + sort_direction)
                            .where(collection_id: @collection.id)
                            .page(params[:page]).per(params[:per_page])
                            .includes(:collection)
  end

  # GET /collection_resources/1
  # GET /collection_resources/1.json
  def show
    @collection_resource = CollectionResource.find(params[:id]).decorate
  end

  # GET /collection_resources/new
  def new
    @collection_resource = CollectionResource.new
    @collection_resource.collection = @collection
  end

  # GET /collection_resources/1/edit
  def edit; end

  # POST /collection_resources
  # POST /collection_resources.json
  def create
    @collection_resource = CollectionResource.new collection_resource_params
    @collection_resource.collection = @collection

    respond_to do |format|
      if @collection_resource.save
        format.html do
          redirect_to collection_collection_resource_path(@collection,
                                                          @collection_resource),
                      notice: I18n.t('meta.defaults.messages.success.created',
                                     entity: 'Collection Resource')
        end
      else
        # TODO: Is this right?
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /collection_resources/1
  # PATCH/PUT /collection_resources/1.json
  def update
    respond_to do |format|
      if @collection_resource.update collection_resource_params
        format.html do
          redirect_to collection_collection_resource_path(@collection,
                                                          @collection_resource),
                      notice: I18n.t('meta.defaults.messages.success.updated',
                                     entity: 'Collection Resource')
        end
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /collection_resources/1
  # DELETE /collection_resources/1.json
  def destroy
    @collection_resource.destroy
    respond_to do |format|
      format.html do 
        redirect_to collection_collection_resources_path(@collection),
                    notice: I18n.t('meta.defaults.messages.success.destroyed',
                                   entity: 'Collection Resource')
      end
    end
  end

  private

  def collection_resource_params
    params.require(:collection_resource)
          .permit(:collection_id, :slug, :position, :title, :content)
  end

  def set_collection
    @collection = Collection.find(params[:collection_id])
  end

end
