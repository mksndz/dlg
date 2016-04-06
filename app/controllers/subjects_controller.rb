class SubjectsController < ApplicationController

  load_and_authorize_resource
  include ErrorHandling
  include Sorting
  layout 'admin'

  # GET /subjects
  def index
    @subjects = Subject
                    .order(sort_column + ' ' + sort_direction)
                    .page(params[:page])
  end

  # GET /subjects/1
  def show
  end

  # GET /subjects/new
  def new
    @subject = Subject.new
  end

  # GET /subjects/1/edit
  def edit
  end

  # POST /subjects
  def create
    @subject = Subject.new(subject_params)
    if @subject.save
      redirect_to subject_path(@subject), notice: 'Subject was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /subjects/1
  def update
    if @subject.update(subject_params)
      redirect_to subject_path(@subject), notice: 'Subject was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /subjects/1
  def destroy
    @subject.destroy
    redirect_to subjects_url, notice: 'Subject was successfully destroyed.'
  end

  private
  def subject_params
    params.require(:subject).permit(:name)
  end
end

