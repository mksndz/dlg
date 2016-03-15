module ApplicationHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  # set menu items as 'active'
  def admin_active_class(key)
    request.original_url.include?('/' + key) ? 'active' : ''
  end

  def text_field_multi(object, term)
    klass = object.class.name.demodulize.underscore
    html = ''
    html += label_tag "#{klass}[#{term}]", t("activerecord.attributes.#{klass}.#{term}")
    html += text_area_tag "#{klass}[#{term}]", object.method(term).call.join("\n"), { rows: '10', class: 'form-control' }
    html += content_tag :span, t("activerecord.help.#{klass}.#{term}"), { class: 'help-block'}
    html.html_safe
  end

end
