class CollectionsController < ApplicationController

  def index

    @collections = Collection.all

  end

  def new

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

  def collection_params
    params.require(:collection).permit!
  end

end
