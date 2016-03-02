class UsersController < ApplicationController

  load_and_authorize_resource

  layout 'admin'

  helper_method :sort_column, :sort_direction

  def index
    @users = User
                 .order(sort_column + ' ' + sort_direction)
                 .page(params[:page])
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: 'User created!'
    else
      render :new, alert: 'User could not be created!'
    end
  end

  def update
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
      params.require(:user).permit(:email, :password, :password_confirmation, :role_ids => [])
    end

    def sort_column
      User.column_names.include?(params[:sort]) ? params[:sort] : 'id'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

end
