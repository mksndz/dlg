class OaiSupportController < ApplicationController

  respond_to :json

  before_action :authenticate_token, :set_rows
  before_action :set_class, except: :deleted

  def dump

    q = @class
      .page(params[:page])
      .per(@rows)
      .order(id: :asc)

    q = q.updated_since(params[:date]) if params[:date]

    q = q.includes(:collection).includes(:repository) if @class == Item
    q = q.includes(:repository) if @class == Collection


    total_count = q.total_count

    dump = q.map do |i|
      {
          id: i.id,
          public: i.public,
          record_id: record_id(i),
          updated_at: i.updated_at
      }
    end

    response = {
        total_count: total_count,
        page: params[:page],
        rows: @rows,
        records: dump
    }

    render json: response

  end

  def deleted

    deleted_items = ItemVersion
                        .unscoped
                        .where(event: 'destroy')
                        .page(params[:page])
                        .per(@rows)

    if params[:date]
      deleted_items = deleted_items.where('created_at > ?', params[:date])
    end

    dump = deleted_items.map do |di|

      i = di.reify

      {
          id: 'deleted',
          public: i.public,
          record_id: record_id(i),
          updated_at: di.created_at
      }

    end

    total_count = dump.length

    response = {
        total_count: total_count,
        page: params[:page],
        rows: @rows,
        records: dump
    }

    render json: response

  end

  def metadata

    @records = @class.where(id: params[:ids].split(','))

    render json: @records

  end

  private

  def strong_params
    params.permit(
              :rows,
              :date,
              :class,
              :page
    )
  end

  def set_class
    if params[:class].nil?
      head(:bad_request)
    else
      case params[:class].downcase
        when 'item'
          @class = Item
        when 'repository'
          @class = Repository
        when 'collection'
          @class = Collection
        else
          head :bad_request
      end
    end
  end

  def set_rows
    if params[:rows].nil? || params[:rows].to_i <= 0
      @rows = 50
    elsif params[:rows].to_i > 50000
      @rows = 50000
    else
      @rows = params[:rows]
    end
  end

  def authenticate_token
    if Devise.secure_compare request.headers['X-User-Token'], Rails.application.secrets.oai_token
      true
    else
      head :unauthorized
    end
  end

  def record_id(r)
    case @class
      when Item
        "#{r.repository.slug}_#{r.collection.slug}_#{r.slug}"
      when Collection
        "#{r.repository.slug}_#{r.slug}"
      else
        "#{r.slug}"
    end
  end

end