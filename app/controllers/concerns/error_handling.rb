module ErrorHandling
  extend ActiveSupport::Concern

  included do

    rescue_from CanCan::AccessDenied do
      redirect_to root_url, alert: 'You are not authorized to perform that action.'
    end

    rescue_from ActiveRecord::RecordNotFound do
      redirect_to(action: 'index')
    end

    # todo handle these types of errors specifically
    rescue_from ArgumentError do
      redirect_to(action: 'index')
    end

  end

end