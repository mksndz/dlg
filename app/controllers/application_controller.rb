class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  include Blacklight::Controller

  layout 'blacklight'

  before_action :set_paper_trail_whodunnit
  before_action :authenticate_user!
  before_action :prepare_exception_notifier

  protect_from_forgery with: :exception

  def user_for_paper_trail
    current_user ? current_user.id : nil
  end

  private

  def prepare_exception_notifier
    request.env['exception_notifier.exception_data'] = {
      current_user: current_user ? current_user.email : 'none'
    }
  end

end
