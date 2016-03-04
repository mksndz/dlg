class UsersController < ApplicationController

  load_and_authorize_resource
  layout 'admin'
  include Sorting

  def index
    if current_user.coordinator?
      @users = User.where(creator_id: current_user.id)
                   .order(sort_column + ' ' + sort_direction)
                   .page(params[:page])
    else
      @users = User
                   .order(sort_column + ' ' + sort_direction)
                   .page(params[:page])
    end

  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    set_user_creator
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: 'User created!'
    else
      render :new, alert: 'User could not be created!'
    end
  end

  def update
    delete_creator_param unless current_user.admin?
    if @user.update(user_params)
        redirect_to @user, notice: 'User updated!'
    else
        render :edit, alert: 'User could not be updated!'
    end
  end

  def destroy
    # todo determine if a soft delete would be better for users
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private

    def set_roles
      @roles = Role.all
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :creator_id, :role_ids => [])
    end

    def delete_creator_param
      user_params.delete(:creator_id)
    end

    def set_user_creator
      @user.creator = current_user
    end

end
