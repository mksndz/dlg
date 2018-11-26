module Api
  module V2
    # API v2 controller for Collections
    class CollectionsController < BaseController
      def index
        @collections = Collection.all
        filter_collections_by_portal
        render json: @collections.page(params[:page])
                                 .per(params[:per_page])
      end

      def show
        collection = if record_id? params[:id]
                       Collection.find_by_record_id params[:id]
                     else
                       Collection.find params[:id]
                     end
        render json: collection, include: %i[portals]
      end

      private

      def record_id?(id)
        id =~ /^[a-zA-Z0-9-]+_[a-zA-Z0-9-]+$/
      end

      def filter_collections_by_portal
        return unless params[:portal]

        @collections = @collections.includes(:portals)
                                   .joins(:portals)
                                   .where(portals: { code: params[:portal] })
      end
    end
  end
end