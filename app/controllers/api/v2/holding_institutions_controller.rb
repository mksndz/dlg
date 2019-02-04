module Api
  module V2
    # API v2 controller for HoldingInstitutions
    class HoldingInstitutionsController < BaseController
      def index
        inst_type = params[:type]
        letter = params[:letter]
        @his = HoldingInstitution.all.order(:authorized_name)
        filter_institutions_by_portal
        @his = @his.where(institution_type: inst_type) if inst_type
        @his = @his.where('authorized_name LIKE ?', "#{letter}%") if letter
        render json: @his.page(params[:page])
                         .per(params[:per_page]),
               include: %i[portals],
               methods: :public_collections
      end

      def show
        render json: HoldingInstitution.find_by(slug: params[:id]),
               methods: :public_collections
      end

      private

      def filter_institutions_by_portal
        portal = Portal.where(code: params[:portal]).first
        return unless portal

        @his = @his.includes(:repositories)
                   .where(repositories: { id: portal.repository_ids })
      end
    end
  end
end