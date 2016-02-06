module ItemsHelper
  def warning_highlight(item)
    item.collection ? '' : 'warning'
  end
end
