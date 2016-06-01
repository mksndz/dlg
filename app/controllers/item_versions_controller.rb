class ItemVersionsController < ApplicationController

  authorize_resource

  before_action :set_item_and_version, only: [:diff, :rollback]

  def rollback
    item = @version.reify
    if item.save(validate: false)
      redirect_to edit_item_path(item), notice: 'Item rolled back to selected version'
    else
      redirect_to item_path(item), alert: 'Item could not be rolled back'
    end
  end

  def restore
    version = ItemVersion.find(params[:id])
    @item = version.reify
    @item.save
    version.delete
    redirect_to item_path(@item), notice: 'The deleted Item was restored'
  end

  def diff
  end

  private

  def set_item_and_version
    @item = Item.find(params[:item_id])
    @version = @item.versions.find(params[:id])
  end

end