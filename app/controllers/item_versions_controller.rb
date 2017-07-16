class ItemVersionsController < ApplicationController

  authorize_resource

  before_action :set_item_and_version, only: [:diff, :rollback]

  def rollback
    item = @version.reify
    if item.save(validate: false)
      redirect_to item_path(item), notice: I18n.t('meta.versions.messages.success.rollback')
    else
      redirect_to item_path(item), alert: I18n.t('meta.versions.messages.errors.rollback')
    end
  end

  def restore
    version = ItemVersion.find(params[:id])
    @item = version.reify
    @item.save(validate: false)
    version.delete
    redirect_to item_path(@item), notice: I18n.t('meta.versions.messages.success.restore')
  end

  def diff
  end

  private

  def set_item_and_version
    @item = Item.find(params[:item_id])
    @version = @item.versions.find(params[:id])
  end

end