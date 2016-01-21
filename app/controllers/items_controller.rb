class ItemsController < ApplicationController

  def index

    @items = Item.all

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

  def item_params
    params.require(:item).permit!
  end

end
