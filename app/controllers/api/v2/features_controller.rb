module Api
  module V2
    # API v2 controller for Features
    class FeaturesController < BaseController
      VALID_TYPES = %w[tab carousel].freeze
      def index
        limit = params[:count] || 10
        type = validated_type
        unless type
          head :bad_request
          return
        end
        features = if type == 'tab'
                     Feature.tabs
                   elsif type == 'carousel'
                     Feature.carousel
                   end
        render json: features.limit(limit)
      end

      private

      def validated_type
        params[:type].in?(VALID_TYPES) ? params[:type] : nil
      end
    end
  end
end