class ApiController < ApplicationController
  respond_to :json
  skip_before_action :authenticate_user!
  before_action :authenticate_token
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

  # get featured entities (items, collections)
  def featured
    limit = params[:count] > 10 ? 10 : params[:count]
    records = case params[:type]
              when 'item'
                Feature.items.limit limit
              when 'collection'
                Feature.collections.limit limit
              else
                []
              end
    response = {
      type: params[:type],
      limit: limit,
      records: records.to_json
    }
    render json: response
  end

  private

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
      title: record.title,
      institution: institution_for(record)
    }
  end

  def collection_json_for(record)
    {
      id: record.id,
      title: record.title,
      institution: institution_for(record)
    }
  end

  def institution_for(record)
    record.dcterms_provenance.join ', '
  end
end