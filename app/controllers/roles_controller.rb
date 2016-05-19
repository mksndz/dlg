class RolesController < ApplicationController

  load_and_authorize_resource
  include Sorting
  include ErrorHandling

  # GET /roles
  def index
    @roles = Role.all
  end

  # GET /roles/1
  def show
  end

  # GET /roles/new
  def new
    @role = Role.new
  end

  # GET /roles/1/edit
  def edit
  end

  # POST /roles
  def create
    @role = Role.new(role_params)

    if @role.save
      redirect_to @role, notice: I18n.t('meta.defaults.messages.success.created', entity: 'Role')
    else
      render :new
    end
  end

  # PATCH/PUT /roles/1
  def update
    if @role.update(role_params)
      redirect_to @role, notice: I18n.t('meta.defaults.messages.success.updated', entity: 'Role')
    else
      render :edit
    end
  end

  # DELETE /roles/1
  def destroy
    @role.destroy
    redirect_to roles_url, notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'Role')
  end

  private
  def role_params
    params.require(:role).permit(:name)
  end
end

