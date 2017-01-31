class OaiSupportController < ApplicationController

  respond_to :json

  def dump

    deleted_items = ItemVersion.unscoped.where(event: 'destroy')

    if params[:date]
      items = Item.updated_since params[:date]
      deleted_items = deleted_items.where('created_at > ?', params[:date])
    else
      items = Item
    end

    items = items.includes(:collection).includes(:repository)

    dump = items.map do |i|
      {
          id: i.id,
          public: i.public,
          record_id: "#{i.repository.slug}_#{i.collection.slug}_#{i.slug}",
          updated_at: i.updated_at
      }
    end

    deleted_items.each do |di|

      i = di.reify

      dump << {
          id: 'deleted',
          public: i.public,
          record_id: "#{i.repository.slug}_#{i.collection.slug}_#{i.slug}",
          updated_at: di.created_at
      }

    end

    response = {
        count: dump.length,
        items: dump
    }

    render json: response

  end

  def metadata

    @items = Item.where(id: params[:ids].split(','))

    render json: @items

  end



end