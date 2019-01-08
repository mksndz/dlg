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
    @page = Page.new item: @item, file_type: item_file_type
  end

  def create
    @page = Page.new page_params.merge!(item: @item)
    respond_to do |format|
      if @page.save
        format.html do
          redirect_to item_page_path(@page.item, @page), notice:
            I18n.t('meta.defaults.messages.success.created', entity: 'Page')
        end
      else
        format.html { render :new }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @page.update page_params
        format.html do
          redirect_to item_page_path(@page.item, @page), notice:
            I18n.t('meta.defaults.messages.success.updated', entity: 'Page')
        end
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @page.destroy
        format.html do
          redirect_to item_pages_path(@page.item), notice:
            I18n.t('meta.defaults.messages.success.destroyed', entity: 'Page')
        end
      else
        format.html do
          redirect_to :index, alert:
            I18n.t('meta.defaults.messages.errors.not_deleted', entity: 'Page')
        end
      end
    end
  end

  private

  def page_params
    params.require(:page).permit(:item_id, :fulltext, :title, :number,
                                 :file_type)
  end

  def set_item
    @item = Item.find params[:item_id]
  end

  def item_file_type
    case @item.dc_format.first
    # jpg
    when /jpg/
      'jpg'
    when /jpeg/
      'jpeg'
    when /pdf/
      'pdf'
    end
  end
end
