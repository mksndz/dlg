module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def render_page_title
    if content_for?(:page_title)
      head_page_titleify content_for(:page_title)
    elsif content_for?(:title)
      head_page_titleify content_for(:title)
    elsif @page_title
      head_page_titleify @page_title
    elsif application_name
      application_name
    end
  end

  private

  def head_page_titleify(pre)
    pre + ' - ' + application_name
  end

end