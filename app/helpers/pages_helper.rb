# helper methods for Page handling
module PagesHelper
  def show_iiif_viewer?
    %w[jp2 jpeg jpeg2 jpg png gif tiff].include? @page.file_type
  end

  def uploaded_image_value
    @page.file.url ? image_tag(@page.file.url) : 'File not uploaded via form'
  end

  def page_title(page)
    page.title? ? page.title : 'No Title'
  end
end