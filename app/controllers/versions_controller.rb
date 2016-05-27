class VersionsController < ApplicationController
  # before_action :require_user
  before_action :set_item_and_version, only: [:diff, :rollback, :destroy]

  def diff
  end

  def rollback
    # change the current item to the specified version
    # reify gives you the object of this version
    item = @version.reify
    item.save
    redirect_to edit_item_path(item), alert: 'Item rolled back to selected version'
  end

  private

  def set_item_and_version
    @item = Item.find(params[:item_id])
    @version = @item.versions.find(params[:id])
  end

end