require 'open-uri'

module ItemsHelper
  def legacy_thumbnail_tag(item)
    thumbnail_url = "http://dlg.galileo.usg.edu/#{item.repository.slug}/#{item.collection.slug}/do-th:#{item.slug}"
    begin
      open thumbnail_url
      url = thumbnail_url
    rescue OpenURI::HTTPError
      url = 'no_thumb.png'
    rescue Net::ReadTimeout
      url = 'no_thumb.png'
    end
    image_tag url, class: 'img-thumbnail'
  end

  def item_validation_status(item)
    if item.valid_item
      content_tag(:span, nil, class: 'glyphicon glyphicon-ok', aria: { hidden: true } )
    else
      content_tag(:span, nil, class: 'glyphicon glyphicon-remove', aria: { hidden: true } )
      # todo very hard on page load times when most items are invalid...using staging vm server
      item.validate
      content_tag(:span, nil, class: 'glyphicon glyphicon-remove validation-errors', aria: { hidden: true }, data: { content: errors_html(item.errors), toggle: 'popover' } ) +
        content_tag(:sup, item.errors.count)
    end
  end

  def version_author_name(version)
    user = User.get_version_author(version)
    user ? user.email : ''
  end

  def diff(version1, version2)
    changes = Diffy::Diff.new(version1, version2,
                              include_plus_and_minus_in_html: true,
                              include_diff_info: true
    )
    changes.to_s.present? ? changes.to_s(:html).html_safe : false
  end

  def link_to_edit_previous_document(previous_document)
    if previous_document
      id = previous_document['sunspot_id_ss'].split(' ')[1]
      link_opts = session_tracking_params(previous_document, search_session['counter'].to_i - 1).merge(:class => "previous", :rel => 'prev')
      link_to url_for(controller: :items, action: 'edit', id: id), link_opts do
        content_tag :span, 'Previous Result', :class => 'previous'
      end
    end

  end

  def link_to_edit_next_document(next_document)
    if next_document
      id = next_document['sunspot_id_ss'].split(' ')[1]
      link_opts = session_tracking_params(next_document, search_session['counter'].to_i + 1).merge(:class => "next", :rel => 'next')
      link_to url_for(controller: :items, action: 'edit', id: id), link_opts do
        content_tag :span, 'Next Result', :class => 'next'
      end
    end
  end


  private

  def errors_html(errors)
    html = ''
    errors.each do |field, message|
      html += "<p>#{field} #{message}</p>"
    end
    html
  end

end