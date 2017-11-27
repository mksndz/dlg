# cleans up ItemType metadata
class MetadataCleaner
  include MetadataHelper
  LINE_BREAK_REGEXP = %r{<br>|<br />|<br/>|<BR>|<BR />|<BR/>}
  HREF_REGEXP = /href|HREF/

  def cleaners_chain
    [
      :convert_br_tags,
      :convert_links,
      :strip_whitespace
    ]
  end

  def clean(itemish)
    multivalued_fields.each do |field|
      itemish.send(field).map! do |value|
        next unless value
        new_value = value
        cleaners_chain.each do |cleaner|
          new_value = send cleaner, new_value
        end
        new_value
      end
    end
  end

  private

  def strip_whitespace(val)
    val.strip
  end

  def convert_links(val)
    return val unless val =~ HREF_REGEXP
    links = Nokogiri::HTML(val).search 'a'
    new_val = val
    links.each do |link|
      new_val = convert_link link, new_val
    end
    new_val
  rescue StandardError
    val
  end

  def convert_link(link, val)
    original_link = link.to_s.gsub('&amp;', '&')
    original_href = link['href']
    link_text = link.content
    original_href.gsub!('mailto:', '')
    if link_text == original_href
      val.gsub original_link, link_text
    else
      val.gsub original_link, "#{link_text} (#{original_href})"
    end
  end

  def convert_br_tags(val)
    return val unless val =~ LINE_BREAK_REGEXP
    new_val = val.gsub LINE_BREAK_REGEXP, "\n"
    new_val.gsub("\n\n\n", "\n").gsub("\n\n", "\n")
  end

end