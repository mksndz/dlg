module Api
  module V2
    # API v2 controller for Collection Resources
    class CollectionResourcesController < BaseController
      def show
        collection = Collection.find_by record_id: params[:collection]
        resource = CollectionResource.find_by(
          collection: collection, slug: params[:slug])

        render json: resource, except: %i[collection_id raw_content],
               include: { collection: { only: %i[record_id display_title] } }
      rescue ActiveRecord::NotFound => _
        # TODO: return error message
        head :not_found
      end
    end
  end
end