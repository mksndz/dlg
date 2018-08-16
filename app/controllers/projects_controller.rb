class ProjectsController < ApplicationController

  load_and_authorize_resource
  include ErrorHandling
  include Sorting

  # GET /projects
  def index
    @projects = Project
                    .order(sort_column + ' ' + sort_direction)
                    .page(params[:page])
  end

  # GET /projects/1
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to project_path(@project), notice: I18n.t('meta.defaults.messages.success.created', entity: 'Project')
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to project_path(@project), notice: I18n.t('meta.defaults.messages.success.updated', entity: 'Project')
    else
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to projects_url, notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'Project')
  end

  private
  def project_params
    params.require(:project).permit(:title, :fiscal_year, :hosting, 
                                    :storage_used, :holding_institution_id)
  end
end

