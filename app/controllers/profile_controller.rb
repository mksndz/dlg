class ProfileController < ApplicationController

  authorize_resource class: false

  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update user_params.except(:utf8, :_method, :commit)
      bypass_sign_in @user
      redirect_to root_path, notice: I18n.t('meta.profile.messages.success.password_changed')
    else
      render :edit
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.permit(
       :utf8,
       :_method,
       :commit,
       :password,
       :password_confirmation
    )
  end

end
