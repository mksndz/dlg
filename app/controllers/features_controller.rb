# controller for Feature features :)
class FeaturesController < ApplicationController
  load_and_authorize_resource
  include ErrorHandling
  include Sorting
  # GET /features
  def index
    @features = Feature
                .order(sort_column + ' ' + sort_direction)
                .page(params[:page])
  end

  # GET /features/1
  def show; end

  # GET /features/new
  def new
    @feature = Feature.new
  end

  # GET /features/1/edit
  def edit; end

  # POST /features
  def create
    @feature = Feature.new(feature_params)
    if @feature.save
      redirect_to feature_path(@feature), notice: I18n.t('meta.defaults.messages.success.created', entity: 'Feature')
    else
      render :new
    end
  end

  # PATCH/PUT /features/1
  def update
    if @feature.update(feature_params)
      redirect_to feature_path(@feature), notice: I18n.t('meta.defaults.messages.success.updated', entity: 'Feature')
    else
      render :edit
    end
  end

  # DELETE /features/1
  def destroy
    @feature.destroy
    redirect_to features_url, notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'Feature')
  end

  private

  def feature_params
    params.require(:feature).permit(:title, :title_link, :institution,
                                    :institution_link, :short_description,
                                    :external_link, :primary, :image,
                                    :remove_image, :image_cache, :area,
                                    :large_image, :remove_large_image,
                                    :large_image_cache, :public)
  end
end
