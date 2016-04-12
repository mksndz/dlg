class InvitationsController < Devise::InvitationsController

  after_action :set_user_creator, only: [:update]

  # show all pending invitations
  def index
    @pending_invitations = User.pending_invitation_response
    render 'index'
  end

  def update
    super
  end

  private

  def set_user_creator
    resource.creator = resource.invited_by if resource.is_a? User
  end


end