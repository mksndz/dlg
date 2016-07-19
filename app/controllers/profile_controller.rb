class ProfileController < ApplicationController

  authorize_resource class: false

  before_action :set_user

  def show

  end

  # modify users editable information
  def edit

  end

  # update user model
  def update
    if @user.update user_params
      sign_in @user, bypass: true
      redirect_to root_path, notice: I18n.t('meta.profile.messages.success.password_changed')
    else
      # message = @user.errors.messages.first
      # flash[:error] = "Your new password #{message[:password]}"
      render :edit
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.permit(
       :password,
       :password_confirmation
    )
  end

end
