# frozen_string_literal: true

# controller for fulltext ingests actions
class FulltextIngestsController < ApplicationController

  load_and_authorize_resource

  include ErrorHandling
  include Sorting

  # show all ingests
  def index
    @fulltext_ingests = FulltextIngest.order(sort_column + ' ' + sort_direction)
                                      .page(params[:page])
                                      .per(params[:per_page])
  end

  # show form to create a new fulltext ingest
  def new
    @fulltext_ingest = FulltextIngest.new
  end

  # create a fulltext ingest and queue ingest job
  def create
    @fulltext_ingest.user = current_user
    @fulltext_ingest.queued_at = Date.today
    @fulltext_ingest.save(fulltext_ingest_params)
    Resque.enqueue(FulltextProcessor, @fulltext_ingest.id)
    respond_to do |format|
      format.html do
        redirect_to(
          fulltext_ingest_path(@fulltext_ingest),
          notice: I18n.t('meta.fulltext_ingests.messages.success.queued')
        )
      end
    end
  end

  def show; end

  def destroy
    # clear fulltext field on modified records and set undone_at field
    if undo?
      redirect_to fulltext_ingest_path(@fulltext_ingest), notice: I18n.t('meta.fulltext_ingests.messages.success.undone')
    else
      redirect_to fulltext_ingest_path(@fulltext_ingest), notice: I18n.t('meta.fulltext_ingests.messages.errors.could_not_undo')
    end
  end

  private

  def fulltext_ingest_params
    params.require(:fulltext_ingest).permit(:title, :description, :file,
                                            :file_cache, :user_id)
  end

  def undo?
    @fulltext_ingest.finished_at && @fulltext_ingest.undo
  end

end
