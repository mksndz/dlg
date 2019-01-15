# controller for page ingests actions
class PageIngestsController < ApplicationController
  load_and_authorize_resource
  include ErrorHandling
  include Sorting

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
    build_ingest
    if @page_ingest.save
      Resque.enqueue(PageProcessor, @page_ingest.id)
      redirect_to(
        page_ingest_path(@fulltext_ingest),
        notice: I18n.t('meta.page_ingests.messages.success.queued')
      )
    else
      render :new, I18n.t('meta.defaults.messages.errors.not_created', entity: 'Page Ingest')
    end
  end

  def show; end

  def destroy
    # TODO why have this?
  end

  private

  def page_ingest_params
    params.require(:fulltext_ingest).permit(:title, :description, :file,
                                            :file_cache, :user_id)
  end

  def build_ingest
    @page_ingest = PageIngest.new page_ingest_params
    @page_ingest.user = current_user
    @page_ingest.queued_at = Date.today
  end

end
