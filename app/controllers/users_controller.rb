class UsersController < ApplicationController

  load_and_authorize_resource

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
    if current_user.coordinator?
      @admins = Admin.where(creator_id: current_user.id)
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
    @admin = Admin.new(user_params)
    set_user_creator
    set_default_roles
    if @admin.save
      redirect_to user_path(@admin), notice: 'Admin created!'
    else
      render :new, alert: 'Admin could not be created!'
    end
  end

  def edit
  end

  def update
    if @admin.update(user_params)
      redirect_to user_path(@admin), notice: 'Admin updated!'
    else
      render :edit, alert: 'Admin could not be updated!'
    end
  end

  def destroy
    # todo determine if a soft delete would be better for users
    @admin.destroy
    redirect_to admins_url, notice: 'Admin was successfully destroyed.'
  end

  private

  def set_roles
    @roles = Role.all
  end

  def user_params
    params.require(:admin).permit(:email, :password, :password_confirmation, :creator_id, role_ids: [], repository_ids: [], collection_ids: [])
  end

  def set_user_creator
    @admin.creator = current_user
  end

  def set_data
    @data ||= {}
    @data[:roles] = Role.where("name != 'basic'")
    @data[:repositories]= current_user.super? ? Repository.all : current_user.repositories
    @data[:collections] = current_user.super? ? Collection.all : current_user.collections
  end

  def confirm_restrictions
    # todo test coverage for this
    unless current_user.super?
      new_user_collection_ids = user_params[:collection_ids] || []
      new_user_repository_ids = user_params[:repository_ids] || []
      throw AdminRestrictionsError unless (new_user_repository_ids - current_user.repository_ids).empty?
      throw AdminRestrictionsError unless (new_user_collection_ids - current_user.collection_ids).empty?
      throw AdminRestrictionsError if current_user.coordinator? and user_params[:role_ids]
    end
  end

  def set_default_roles
    @admin.roles << Role.where(name: 'basic')
  end

end
