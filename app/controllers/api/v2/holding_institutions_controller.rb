module Api
  module V2
    # API v2 controller for HoldingInstitutions
    class HoldingInstitutionsController < BaseController
      def index
        institution_type = params[:type]
        @his = HoldingInstitution.all
        @his.where(institution_type: institution_type) if institution_type
        render json: @his.page(params[:page])
                         .per(params[:per_page]), include: :collections
      end

      def show
        render json: HoldingInstitution.find(params[:id]), include: :collections
      end
    end
  end
end