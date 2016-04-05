module Meta
  class InvitationsController < Devise::InvitationsController

    authorize_resource class: false, except: [:edit, :update]

    layout 'admin'

    # include this from module???
    def current_ability
      @current_ability ||= AdminAbility.new(current_meta_admin)
    end

  end
end