require 'open-uri'

module ItemsHelper
  def legacy_thumbnail_tag(item)
    thumbnail_url = "http://dlg.galileo.usg.edu/#{item.repository.slug}/#{item.collection.slug}/do-th:#{item.slug}"
    begin
      open(thumbnail_url)
      image_tag(thumbnail_url, class: 'img-thumbnail')
    rescue OpenURI::HTTPError
      image_tag('no_thumb_stolen.png', class: 'img-thumbnail')
    end
  end

  def item_validation_status(item)
    if item.valid_item
      content_tag(:span, nil, class: 'glyphicon glyphicon-ok', aria: { hidden: true } )
    else
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

  private

  def errors_html(errors)
    html = ''
    errors.each do |field, message|
      html += "<p>#{field} #{message}</p>"
    end
    html
  end

end