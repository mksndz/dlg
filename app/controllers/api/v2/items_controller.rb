module Api
  module V2
    # API v2 controller for Items
    class ItemsController < BaseController
      def index
        @items = Item.where public: true
        filter_items_by_portal
        filter_items_by_collection
        render json: @items.page(params[:page])
                           .per(params[:per_page]),
               include: { collection: { only: :display_title } }
      end

      def show
        item = if numerical? params[:id]
                 Item.find params[:id]
               else
                 Item.find_by_record_id params[:id]
               end
        raise ActiveRecord::RecordNotFound unless item.public?

        render json: item, include: %i[portals collection]
      end

      private

      def numerical?(id)
        id =~ /^[0-9]+$/
      end

      def filter_items_by_portal
        return unless params[:portal]

        @items = @items.includes(:portals)
                       .joins(:portals)
                       .where(portals: { code: params[:portal] })
      end

      def filter_items_by_collection
        return unless params[:collection]

        @items = if numerical? params[:collection]
                   @items.where(collection_id: params[:collection])
                 else
                   @items.includes(:collection)
                         .where(collections: { record_id: params[:collection] })
                 end
      end
    end
  end
end