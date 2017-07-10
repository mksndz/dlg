class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller
  layout 'blacklight'

  before_filter :set_paper_trail_whodunnit
  before_action :authenticate_user!

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def user_for_paper_trail
    current_user ? current_user.id : nil;
  end

end
