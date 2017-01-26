class OaiSupportController < ApplicationController

  respond_to :json

  def dump

    # todo a limit? or pagination?
    items = Item.all
                 .includes(:collection)
                 .includes(:repository)

    z = items.map do |i|
      {
          id: i.id,
          record_id: "#{i.repository.slug}_#{i.collection.slug}_#{i.slug}",
          updated_at: i.updated_at
      }
    end

    respond_with z.to_json

    # simple, but takes way too long
    # respond_with Item.all.to_json methods: :record_id

  end

  def metadata

    ids = params[:ids]

    respond_with Item.where(id: ids).to_json

  end

  def diff

    since = params[:since]

    # todo validate and confirm datetime

    respond_with Item.where(:updated_at >= since).to_json

  end

  private



end