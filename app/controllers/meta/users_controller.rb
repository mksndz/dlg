module Meta
  class UsersController < BaseController

    load_and_authorize_resource
    layout 'admin'
    include Sorting
    include ErrorHandling

    before_action :set_data, only: [:new, :edit]
    before_action :confirm_restrictions, only: [:create, :update]

    class UserRestrictionsError < StandardError
    end

    rescue_from UserRestrictionsError do
      redirect_to :back, alert: 'You have attempted to give a user rights that you do not have.'
    end


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
      set_data
      @user = User.new
    end

    def create
      set_user_creator
      set_default_roles

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
      redirect_to meta_users_url, notice: 'User was successfully destroyed.'
    end

    private

    def set_roles
      @roles = Role.all
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :creator_id, role_ids: [], repository_ids: [], collection_ids: [])
    end

    def set_user_creator
      @user.creator = current_user
    end

    def set_data
      @data ||= {}
      @data[:roles] = Role.where("name != 'basic'")
      @data[:repositories]= current_user.admin? ? Repository.all : current_user.repositories
      @data[:collections] = current_user.admin? ? Collection.all : current_user.collections
    end

    def confirm_restrictions
      new_user_collection_ids = user_params[:collection_ids] || []
      new_user_repository_ids = user_params[:repository_ids] || []
      throw UserRestrictionsError unless (new_user_repository_ids - current_user.repository_ids).empty?
      throw UserRestrictionsError unless (new_user_collection_ids - current_user.collection_ids).empty?
      throw UserRestrictionsError if current_user.coordinator? and user_params[:role_ids]
    end

    def set_default_roles
      @user.roles << Role.where(name: 'basic')
    end

  end
end
