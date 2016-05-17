module ErrorHandling
  extend ActiveSupport::Concern

  included do

    rescue_from CanCan::AccessDenied do |e|
      redirect_to root_url, alert: e.message
    end

    rescue_from ActiveRecord::RecordNotFound do
      redirect_to({action: 'index'}, alert: 'Record not found.')
    end

  end

end