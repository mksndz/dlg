module ItemsHelper
  def warning_highlight(item)
    item.collection ? '' : 'warning'
  end

  def show_search_panel
    params[:search] ? 'in' : ''
  end
end