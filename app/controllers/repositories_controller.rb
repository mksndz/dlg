class RepositoriesController < ApplicationController

  def index

    @repositories = Repository.all

  end

  def new

    @repository = Repository.new

  end

  def create

  end

  def edit

  end

  def update

  end

  def destroy

  end

  private

  def repository_params
    params.require(:repository).permit!
  end

end
