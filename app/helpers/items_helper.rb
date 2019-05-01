module ItemsHelper
  def show_item_iiif_viewer?
    @item.pages.any? && show_iiif_viewer?
  end

  def legacy_thumbnail_tag(item) # todo this duplicates functionality in BlacklightHelper
    url = "http://dlg.galileo.usg.edu/#{item.repository.slug}/#{item.collection.slug}/do-th:#{item.slug}"
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

  def portal_badges(rec)
    labels = []
    rec.portals.each do |p|
      labels << content_tag(:span, p.code, class: 'label label-primary')
    end
    labels.join('<br />').html_safe
  end

  def version_author_name(version)
    user = User.get_version_author(version)
    user ? user.email : 'A Deleted User'
  end

  def diff(version1, version2)
    changes = Diffy::Diff.new(version1, version2,
                              include_plus_and_minus_in_html: true,
                              include_diff_info: true
                           )
    changes.to_s.present? ? changes.to_s(:html).html_safe : false
  end

  def pages_link_for(item)
    pages = item.pages_count || '0'
    link_to pages, item_pages_path(item), class: 'pages-link badge'
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