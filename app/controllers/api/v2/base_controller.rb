module Api
  module V2
    # shared stuff for api controllers
    class BaseController < ActionController::Base
      respond_to :json
      before_action :authenticate_token
      rescue_from(ActiveRecord::RecordNotFound) { head :not_found }

      def ok
        head :ok
      end

      private

      def authenticate_token
        if Devise.secure_compare request.headers['X-User-Token'], Rails.application.secrets.api_token
          true
        else
          head :unauthorized
        end
      end
    end
  end
end
