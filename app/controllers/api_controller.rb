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
    when 0
      render json: repository_json_for(Repository.find_by!(slug: params[:record_id]))
    else
      render json: {}
    end
  end

  def featured
    # get featured entities (items, collections)
    limit = params[:count] > 10 ? 10 : params[:count]
    records = case params[:type]
              when 'item'
                # TODO: support Item.where(featured: true).limit limit
                Item.all.limit limit
              when 'collection'
                # Collection.where(featured: true).limit limit
                Collection.all.limit limit
              else
                []
              end
    response = {
      type: params[:type],
      limit: limit,
      records: featured_json_for(records)
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

  def featured_json_for(record)
    {
      title: record.title,
      # image_src: record.featured.image_src,
      institution: institution_for(record),
      # link_url: record.featured.link_url
    }
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

  def repository_json_for(record)
    {}
  end

  def institution_for(record)
    record.dcterms_provenance.join ', '
  end
end