module Meta
  class UsersController < BaseController

    load_and_authorize_resource
    layout 'admin'
    include Sorting
    include ErrorHandling


    def index
      @users = User
                   .order(sort_column + ' ' + sort_direction)
                   .page(params[:page])
    end

    def show
    end

    def destroy
      @user.destroy
      redirect_to meta_users_url, notice: 'User was successfully destroyed.'
    end

  end
end
