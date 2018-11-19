module Api
  module V2
    # API v2 controller for HoldingInstitutions
    class HoldingInstitutionsController < BaseController
      def index
        inst_type = params[:type]
        letter = params[:letter]
        @his = HoldingInstitution.all
        @his = @his.where(institution_type: inst_type) if inst_type
        @his = @his.where('authorized_name LIKE ?', "#{letter}%") if letter
        render json: @his.page(params[:page])
                         .per(params[:per_page]), include: :collections
      end

      def show
        render json: HoldingInstitution.find(params[:id]), include: :collections
      end
    end
  end
end