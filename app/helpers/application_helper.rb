module ApplicationHelper

  def boolean_facet_labels(value)
    value == 'true' ? 'Yes' : 'No'
  end

  # handle linking in catalog results
  def linkify(options={})
    url = options[:value].first
    link_to url, url
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, params.merge(sort: column, direction: direction), :class => css_class
  end

  # set menu items as 'active'
  def admin_active_class(key)
    request.original_url.include?('/' + key) ? 'active' : ''
  end

  def meta_textarea(object, term)
    klass = object.class.name.demodulize.underscore
    html = ''
    html += label_tag "#{klass}[#{term}]", t("activerecord.attributes.#{klass}.#{term}")
    html += text_area_tag "#{klass}[#{term}]", object.method(term).call.join("\n"), { rows: '10', class: 'form-control' }
    html += content_tag :span, t("activerecord.help.#{klass}.#{term}"), { class: 'help-block'}
    html.html_safe
  end

  def boolean_check_icon(value)
    value ? content_tag(:span, nil, class: 'glyphicon glyphicon-ok') : ''
  end

  def per_page_values
    [20, 50, 100, 250]
  end

  def per_page_selected(pp)
    params[:per_page].to_i == pp ? 'btn-primary' : 'btn-default'
  end

  def valid_url?(url)
    begin
      open url do |r|
        return false if r.status.include? '404'
      end
    rescue OpenURI::HTTPError
      return false
    end
    true
  end

end
