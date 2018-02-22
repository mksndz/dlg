class UsersController < ApplicationController

  load_and_authorize_resource

  include Sorting
  include ErrorHandling

  before_action :set_data, only: [:new, :edit]
  before_action :confirm_restrictions, only: [:create, :update]

  # todo put into its own file with other bespoke exceptions
  class UserRestrictionsError < StandardError
  end

  rescue_from UserRestrictionsError do |e|
    redirect_to :back, alert: I18n.t('meta.user.messages.errors.user_restriction_error')
  end


  def index
    if current_user.coordinator?
      @users = User.active
                   .where(creator_id: current_user.id)
                   .order(sort_column + ' ' + sort_direction)
                   .page(params[:page])
                   .per(params[:per_page])
    else
      @users = User.active
                   .order(sort_column + ' ' + sort_direction)
                   .page(params[:page])
                   .per(params[:per_page])
    end
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    set_user_creator
    if @user.save
      redirect_to user_path(@user), notice: I18n.t('meta.defaults.messages.success.created', entity: 'User')
    else
      set_data
      render :new, alert: I18n.t('meta.defaults.messages.errors.not_created', entity: 'User')
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: I18n.t('meta.defaults.messages.success.updated', entity: 'User')
    else
      set_data
      render :edit, alert: I18n.t('meta.defaults.messages.errors.not_updated', entity: 'User')
    end
  end

  def destroy
    # todo determine if a soft delete would be better for users
    @user.destroy
    redirect_to users_url, notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'User')
  end

  private

  def tf_checkbox(value)
    value === '1' ? true : false
  end

  def params_contain_role_info
    if (tf_checkbox(user_params[:is_super]) ||
      tf_checkbox(user_params[:is_coordinator]) ||
      tf_checkbox(user_params[:is_uploader]) ||
      tf_checkbox(user_params[:is_viewer]) ||
      tf_checkbox(user_params[:is_committer]))
      true
    else
      false
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :creator_id, :is_super, :is_coordinator, :is_uploader, :is_viewer, :is_committer, repository_ids: [], collection_ids: [])
  end

  def set_user_creator
    @user.creator = current_user
  end

  def set_data
    @data ||= {}
    if current_user.super?
      @data[:repositories]= Repository.all.order('title')
      @data[:collections] = Collection.all.order('display_title')
    else
      @data[:repositories]= current_user.repositories.order('title')
      @data[:collections] = current_user.collections.order('display_title')
    end

  end

  def confirm_restrictions
    unless current_user.super?
      new_user_collection_ids = user_params[:collection_ids] || []
      new_user_repository_ids = user_params[:repository_ids] || []
      super_user_collection_ids = current_user.repository_ids || []
      super_user_repository_ids = current_user.collection_ids || []
      new_user_collection_ids.reject! { |i| i.empty? }
      new_user_repository_ids.reject! { |i| i.empty? }
      raise UserRestrictionsError unless (new_user_repository_ids - super_user_repository_ids).empty?
      raise UserRestrictionsError unless (new_user_collection_ids - super_user_collection_ids).empty?
      raise UserRestrictionsError if params_contain_role_info
    end
  end

end
