# controller for page ingests actions
class PageIngestsController < ApplicationController
  load_and_authorize_resource
  include ErrorHandling
  include Sorting

  rescue_from ImportFailedError do |e|
    redirect_to new_page_ingest_path, alert: e.message
  end

  # show all ingests
  def index
    @page_ingests = PageIngest.order(sort_column + ' ' + sort_direction)
                              .page(params[:page])
                              .per(params[:per_page])
  end

  # show form to create a new page ingest
  def new
    @page_ingest = PageIngest.new
  end

  # create a page ingest and queue ingest job
  def create
    if build_ingest
      Resque.enqueue(PageProcessor, @page_ingest.id)
      redirect_to(
        @page_ingest,
        notice: I18n.t('meta.page_ingests.messages.success.queued')
      )
    else
      render :new, alert: I18n.t('meta.defaults.messages.errors.not_created', entity: 'Page Ingest')
    end
  end

  def show; end

  def destroy
    # TODO should pages be deleted?
  end

  private

  def page_ingest_params
    params.require(:page_ingest).permit(:title, :description, :file,
                                        :file_cache, :page_json)
  end

  def build_ingest
    @page_ingest = PageIngest.new(page_ingest_params)
    @page_ingest.user = current_user
    @page_ingest.queued_at = Time.zone.now
    @page_ingest.page_json = deduce_json_source
    @page_ingest.save
  end

  def deduce_json_source
    file = params[:page_ingest][:file]
    text = page_ingest_params[:page_json]
    if json_text?(text) && file
      raise(ImportFailedError,
            I18n.t('meta.page_ingests.messages.errors.both_types'))
    end
    if file
      unless file.respond_to? :read
        raise(ImportFailedError,
              I18n.t('meta.page_ingests.messages.errors.file_error'))
      end
      file.read
    elsif text.present?
      text.strip
    else
      raise(ImportFailedError,
            I18n.t('meta.batch_import.messages.errors.no_data'))
    end
  end

  def json_text?(text)
    text != '{}' && text.present?
  end

end
