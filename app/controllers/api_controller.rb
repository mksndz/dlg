class ApiController < ApplicationController
  respond_to :json
  skip_before_action :authenticate_user!
  before_action :authenticate_token
  before_action :set_limit, only: [:tab_features, :carousel_features]
  rescue_from(ActiveRecord::RecordNotFound) { head :not_found }

  def info
    # get info for record_id
    case params[:record_id].count '_'
    when 2
      render json: item_json_for(Item.find_by!(record_id: params[:record_id]))
    when 1
      render json: collection_json_for(Collection.find_by!(record_id: params[:record_id]))
    else
      render json: {}
    end
  end

  # get features for the tabs
  def tab_features
    records = Feature.tabs.random.limit @limit
    response = { limit: @limit, records: records }
    render json: response
  end

  # get features for the carousel
  def carousel_features
    records = Feature.carousel.limit @limit
    response = { limit: @limit, records: records }
    render json: response
  end

  private

  def set_limit
    @limit = params[:count] || 10
  end

  def authenticate_token
    if Devise.secure_compare request.headers['X-User-Token'], Rails.application.secrets.api_token
      true
    else
      head :unauthorized
    end
  end

  def item_json_for(record)
    {
      id: record.record_id,
      display_title: record.title,
      title: record.dcterms_title,
      institution: record.dcterms_provenance,
      creator: record.dcterms_creator,
      subject: record.dcterms_subject,
      description: record.dcterms_description,
      url: record.edm_is_shown_at,
      date: record.dc_date,
      location: record.dcterms_spatial,
      format: record.dc_format,
      rights: record.dc_right,
      type: record.dcterms_type,
      orig_coll: record.dcterms_is_part_of,
      is_shown_at: record.edm_is_shown_at
    }
  end

  def collection_json_for(record)
    {
      id: record.record_id,
      display_title: record.display_title,
      short_description: record.short_description,
      title: record.dcterms_title,
      institution: record.dcterms_provenance,
      creator: record.dcterms_creator,
      subject: record.dcterms_subject,
      description: record.dcterms_description,
      url: record.edm_is_shown_at,
      date: record.dc_date,
      location: record.dcterms_spatial,
      format: record.dc_format,
      rights: record.dc_right,
      type: record.dcterms_type,
      orig_coll: record.dcterms_is_part_of,
      is_shown_at: record.edm_is_shown_at,
      image: record.holding_institution_image
    }
  end

end