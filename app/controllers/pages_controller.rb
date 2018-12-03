# controller for Page-related actions
class PagesController < ApplicationController
  load_and_authorize_resource
  include ErrorHandling
  include Sorting
  before_action :set_item, except: :destroy

  def index
    @pages = Page.where(item: @item)
                 .order(sort_column + ' ' + sort_direction)
                 .page(params[:page])
                 .per(params[:per_page])
  end

  def show; end

  def new
    @page = Page.new item: @item
  end

  def create
    @page = Page.new page_params
    @page.item = @item
    respond_to do |format|
      if @page.save
        format.html do
          redirect_to item_page_path(@page.item, @page),
                      notice: I18n.t(
                        'meta.defaults.messages.success.created',
                        entity: 'Page'
                      )
        end
        format.json { render json: :show, status: :created, location: @page }
      else
        format.html do
          redirect_to new_item_page_path,
                      alert: I18n.t(
                        'meta.defaults.messages.errors.not_created',
                        entity: 'Page'
                      )
        end
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @page.update page_params
        format.html do
          redirect_to item_page_path(@page.item, @page),
                      notice: I18n.t(
                        'meta.defaults.messages.success.updated',
                        entity: 'Page'
                      )
        end
      else
        format.html do
          render :edit,
                 alert: I18n.t(
                   'meta.defaults.messages.errors.not_updated',
                   entity: 'Page'
                 )
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      if @page.destroy
        format.html do
          redirect_to item_pages_path(@page.item),
                      notice: I18n.t(
                        'meta.defaults.messages.success.destroyed',
                        entitiy: 'Page'
                      )
        end
      else
        format.html do
          render :index,
                 alert: I18n.t('meta.defaults.messages.errors.not_deleted',
                               entity: 'Page')
        end
      end
    end
  end

  private

  def page_params
    params.require(:page).permit(:item_id, :fulltext, :title, :number)
  end

  def set_item
    @item = Item.find params[:item_id]
  end
end
