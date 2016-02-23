class UsersController < ApplicationController

  layout 'admin'

  # load_and_authorize_resource

  before_action :set_roles, only: [:new, :edit]
  before_action :find_user, only: [:show, :edit, :update, :destroy]

  # rescue_from Exception do
  #   redirect_to :index, alert: 'An Error Occurred'
  # end

  # list all users
  def index
    @users = User.all.page(params[:page])
  end

  # show a users info
  def show
  end

  # show new user form
  def new
    @user = User.new
  end

  # create a new user
  def create

    @user = User.new

    @user.roles = get_roles_from_params unless user_params['roles'].blank?
    @user.email = user_params['email']
    @user.password = user_params['password']

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User created!' }
      else
        format.html { redirect_to new_user_path, alert: 'User could not be created!' }
      end
    end

  end

  # display the edit user info form (different from devise user self-service form)
  def edit
    @roles = Role.all
  end

  # modify a user
  def update

    @user.roles = get_roles_from_params unless user_params['roles'].blank?
    @user.email = user_params['email']
    @user.password = user_params['password']

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User updated!' }
      else
        format.html { redirect_to edit_user_path(@user), alert: 'User could not be updated!' }
      end
    end
  end

  # delete a user
  def destroy
    # todo determine if a soft delete would be better for users
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def get_roles_from_params
    roles = []
    user_params['roles'].each do |role_id|
      unless role_id.blank?
        roles += [Role.find(role_id)]
      end
    end
    roles
  end

  def set_roles
    @roles = Role.all
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :roles => [])
  end

end
