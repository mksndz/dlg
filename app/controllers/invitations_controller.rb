class InvitationsController < Devise::InvitationsController

  after_action :set_user_creator, only: [:update]

  # show all pending invitations
  def index
    @pending_invitations = User.where('invitation_sent_at IS NOT NULL AND invitation_accepted_at IS NULL')
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