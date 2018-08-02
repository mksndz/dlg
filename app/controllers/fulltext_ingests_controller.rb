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

    Resque.enqueue(FulltextProcessor, @fulltext_ingest.id)

    respond_to do |format|
      format.html do
        redirect_to(
          fulltext_ingest_path(@fti),
          notice: I18n.t('meta.fulltext_ingest.messages.success.created')
        )
      end
      # format.js { render :queued }
    end

  end

  def show; end

  def destroy
    @batch_import.destroy
    redirect_to batch_batch_imports_path(@batch), notice: I18n.t('meta.batch_import.messages.success.deleted')
  end

  private

  def fulltext_ingest_params
    params.require(:fulltext_ingest).permit(:title, :description, :file,
                                            :user_id)
  end

end
