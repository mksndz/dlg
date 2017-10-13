module ApplicationHelper

  INDEX_TRUNCATION_VALUE = 2500

  def score_display(options)
    "<span class='badge'>#{options[:value].first}</span>".html_safe
  end

  def boolean_facet_labels(value)
    value == 'true' ? 'Yes' : 'No'
  end

  # handle linking in catalog results
  def linkify(options = {})
    url = options[:value].first
    link_to url, url
  end

  # truncate when displaying search results
  def truncate_index(options = {})
    truncate(
        options[:value].join(I18n.t('support.array.two_words_connector')),
        length: INDEX_TRUNCATION_VALUE,
        omission: I18n.t('meta.search.index.truncated_field')
    )
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, params.merge(sort: column, direction: direction), class: css_class
  end

  # set menu items as 'active'
  def admin_active_class(key)
    request.original_url.include?('/' + key) ? 'active' : ''
  end

  def meta_textarea_label(klass, term)
    label = ''
    label += label_tag "#{term}", t("activerecord.attributes.#{klass}.#{term}")
    label += "&nbsp;<em class='text-muted'>#{term}</em>"
    label.html_safe
  end

  def meta_textarea(object, term)
    klass = object.class.name.demodulize.underscore
    html = '<div class="form-group">'
    # html += label_tag "#{term}", t("activerecord.attributes.#{klass}.#{term}")
    html += meta_textarea_label(klass, term)
    html += text_area_tag"#{klass}[#{term}]", object.method(term).call.join("\n"), { rows: '5', class: 'form-control', id: term }
    # html += content_tag :span, t("activerecord.help.#{klass}.#{term}", default: ''), { class: 'help-block'}
    html += '</div>'
    html.html_safe
  end

  def boolean_check_icon(value)
    value = false if value == 'false'
    value ? content_tag(:span, nil, class: 'glyphicon glyphicon-ok') : ''
  end

  def per_page_values
    [20, 50, 100, 250]
  end

  def per_page_selected(pp)
    return 'btn-primary' if !params[:per_page] && pp == 20
    params[:per_page].to_i == pp ? 'btn-primary' : 'btn-default'
  end

  def link_to_edit_previous_document(previous_document)
    if previous_document
      klass, id = previous_document['sunspot_id_ss'].split(' ')
      link_opts = session_tracking_params(previous_document, search_session['counter'].to_i - 1).merge(class: 'previous', rel: 'prev')
      link_to url_for(controller: klass.downcase.pluralize, action: 'edit', id: id), link_opts do
        content_tag :span, 'Previous Result', class: 'previous'
      end
    end

  end

  def link_to_edit_next_document(next_document)
    if next_document
      klass, id = next_document['sunspot_id_ss'].split(' ')
      link_opts = session_tracking_params(next_document, search_session['counter'].to_i + 1).merge(class: 'next', rel: 'next')
      link_to url_for(controller: klass.downcase.pluralize, action: 'edit', id: id), link_opts do
        content_tag :span, 'Next Result', class: 'next'
      end
    end
  end

end
