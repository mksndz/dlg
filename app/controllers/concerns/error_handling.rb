module ErrorHandling
  extend ActiveSupport::Concern

  included do

    rescue_from CanCan::AccessDenied do
      redirect_to root_url, alert: 'You are not authorized to perform that action.'
    end

    rescue_from ActiveRecord::RecordNotFound do
      redirect_to({action: 'index'}, alert: 'Record not found.')
    end

    rescue_from StandardError do |e|
      redirect_to root_url, alert: e.message
    end

  end

end