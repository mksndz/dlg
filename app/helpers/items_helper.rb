require 'open-uri'

module ItemsHelper
  def legacy_thumbnail_tag(item)
    thumbnail_url = "http://dlg.galileo.usg.edu/#{item.repository.slug}/#{item.collection.slug}/do-th:#{item.slug}"
    begin
      open(thumbnail_url)
      image_tag(thumbnail_url, class: 'img-thumbnail')
    rescue OpenURI::HTTPError => e
      image_tag('no_thumb_stolen.png', class: 'img-thumbnail')
    end
  end
end