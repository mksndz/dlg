class OaiSupportController < ApplicationController

  respond_to :json

  before_action :authenticate_token

  def dump

    if params[:rows].nil? || params[:rows].to_i <= 0
      rows = 50
    elsif params[:rows].to_i > 50000
      rows = 50000
    else
      rows = params[:rows]
    end

    deleted_items = ItemVersion.unscoped.where(event: 'destroy')

    if params[:date]
      items = Item.updated_since params[:date]
      deleted_items = deleted_items.where('created_at > ?', params[:date])
    else
      items = Item
    end

    items = items
                .page(params[:page])
                .per(rows)
                .includes(:collection)
                .includes(:repository)
                .order(id: :asc)

    total_count = items.total_count

    dump = items.map do |i|
      {
          id: i.id,
          public: i.public,
          record_id: record_id(i),
          updated_at: i.updated_at
      }
    end

    deleted_items.each do |di|

      i = di.reify

      dump << {
          id: 'deleted',
          public: i.public,
          record_id: record_id(i),
          updated_at: di.created_at
      }

    end

    response = {
        total_count: total_count,
        page: params[:page],
        rows: rows,
        items: dump
    }

    render json: response

  end

  def metadata

    @items = Item.where(id: params[:ids].split(','))

    render json: @items

  end

  private

  def authenticate_token
    if Devise.secure_compare request.headers['X-User-Token'], Rails.application.secrets.oai_token
      true
    else
      head :unauthorized
    end

  end

  def record_id(r)
    "#{r.repository.slug}_#{r.collection.slug}_#{r.slug}"
  end

end