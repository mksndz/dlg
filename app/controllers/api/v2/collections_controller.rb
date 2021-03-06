module Api
  module V2
    # API v2 controller for Collections
    class CollectionsController < BaseController
      def index
        @collections = Collection.where public: true
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
        raise ActiveRecord::RecordNotFound unless collection && collection.public?

        render json: collection, include: {
          portals: {},
          collection_resources: { only: %i[slug title position] },
          holding_institutions: { only: %i[image display_name authorized_name] }
        }
      end

      private

      def record_id?(id)
        id =~ /^[a-z0-9-]+_[a-z0-9-]+$/
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