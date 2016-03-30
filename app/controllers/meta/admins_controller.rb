module Meta
  class AdminsController < BaseController

    load_and_authorize_resource
    layout 'admin'
    include Sorting
    include ErrorHandling

    before_action :set_data, only: [:new, :edit]
    before_action :confirm_restrictions, only: [:create, :update]

    class AdminRestrictionsError < StandardError
    end

    rescue_from AdminRestrictionsError do
      redirect_to :back, alert: 'You have attempted to give a user rights that you do not have.'
    end


    def index
      if current_admin.coordinator?
        @admins = Admin.where(creator_id: current_admin.id)
                     .order(sort_column + ' ' + sort_direction)
                     .page(params[:page])
      else
        @admins = Admin
                     .order(sort_column + ' ' + sort_direction)
                     .page(params[:page])
      end
    end

    def show
    end

    def new
      set_data
      @admin = Admin.new
    end

    def create
      @admin = Admin.new(admin_params)
      set_admin_creator
      set_default_roles
      if @admin.save
        redirect_to meta_admin_path(@admin), notice: 'Admin created!'
      else
        render :new, alert: 'Admin could not be created!'
      end
    end
    
    def edit
    end

    def update
      if @admin.update(admin_params)
        redirect_to meta_admin_path(@admin), notice: 'Admin updated!'
      else
        render :edit, alert: 'Admin could not be updated!'
      end
    end

    def destroy
      # todo determine if a soft delete would be better for users
      @admin.destroy
      redirect_to meta_admins_url, notice: 'Admin was successfully destroyed.'
    end

    private

    def set_roles
      @roles = Role.all
    end

    def admin_params
      params.require(:admin).permit(:email, :password, :password_confirmation, :creator_id, role_ids: [], repository_ids: [], collection_ids: [])
    end

    def set_admin_creator
      @admin.creator = current_admin
    end

    def set_data
      @data ||= {}
      @data[:roles] = Role.where("name != 'basic'")
      @data[:repositories]= current_admin.super? ? Repository.all : current_admin.repositories
      @data[:collections] = current_admin.super? ? Collection.all : current_admin.collections
    end

    def confirm_restrictions
      # todo test coverage for this
      unless current_admin.super?
        new_admin_collection_ids = admin_params[:collection_ids] || []
        new_admin_repository_ids = admin_params[:repository_ids] || []
        throw AdminRestrictionsError unless (new_admin_repository_ids - current_admin.repository_ids).empty?
        throw AdminRestrictionsError unless (new_admin_collection_ids - current_admin.collection_ids).empty?
        throw AdminRestrictionsError if current_admin.coordinator? and admin_params[:role_ids]
      end
    end

    def set_default_roles
      @admin.roles << Role.where(name: 'basic')
    end

  end
end
