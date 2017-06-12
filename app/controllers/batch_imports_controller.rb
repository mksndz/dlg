class BatchImportsController < ApplicationController

  load_and_authorize_resource

  include ErrorHandling
  include Sorting

  before_action :set_batch, except: [:help]
  before_action :ensure_uncommitted_batch, except: [:index, :show, :xml, :help]

  rescue_from ImportFailedError do |e|
    redirect_to new_batch_batch_import_path(@batch), alert: e.message
  end

  rescue_from BatchCommittedError do |e|
    redirect_to batch_batch_imports_path(@batch), alert: e.message
  end

  # show imports for batch
  def index
    @batch_imports = BatchImport
                         .where(batch_id: @batch.id)
                         .order(sort_column + ' ' + sort_direction)
                         .page(params[:page])
                         .per(params[:per_page])
  end

  # show form to create a new batch import
  def new
    @batch_import = BatchImport.new
    @batch_import.batch = @batch
  end

  # create batch import and queue import job
  def create

    file = params[:batch_import][:xml_file]
    text = batch_import_params[:xml]
    ids = batch_import_params[:item_ids]
    file_name = params[:file].original_filename if file

    fail(
      ImportFailedError,
      I18n.t('meta.batch_import.messages.errors.both_types')
    ) if batch_import_params[:xml].present? && file

    @batch_import = BatchImport.new

    # copy file contents to string if needed
    if file
      if file.respond_to? :read
        @batch_import.xml = file.read # TODO: sanitize xml input
        @batch_import.format = 'file'
      else
        fail(
          ImportFailedError,
          I18n.t('meta.batch_import.messages.errors.file_error')
        )
      end
    elsif text && !text.empty?
      @batch_import.xml = batch_import_params[:xml]
      @batch_import.format = 'text'
    elsif ids
      @batch_import.item_ids = ids.split(',')
      @batch_import.format = 'search query'
    else
      fail(
        ImportFailedError,
        I18n.t('meta.batch_import.messages.errors.no_data')
      )
    end

    @batch_import.user = current_user
    @batch_import.batch = @batch
    @batch_import.validations = run_validations?

    @batch_import.save

    Resque.enqueue(RecordImporter, @batch_import.id)

    respond_to do |format|
      format.html do
        redirect_to(
          batch_batch_import_path(@batch, @batch_import),
          notice: I18n.t('meta.batch_import.messages.success.created')
        )
      end
      format.js { render :queued }
    end

  end

  def show
  end

  def destroy
    @batch_import.destroy
    redirect_to batch_batch_imports_path(@batch), notice: I18n.t('meta.batch_import.messages.success.deleted')
  end

  def help
  end

  def xml
  end

  private

  def set_batch
    @batch = Batch.find(params[:batch_id])
  end

  def batch_import_params
    params.require(:batch_import).permit(:xml, :validations, :item_ids)
  end

  def run_validations?
    batch_import_params[:validations] == '1'
  end

  def ensure_uncommitted_batch
    fail(
      BatchCommittedError,
      I18n.t('meta.batch.messages.errors.batch_already_committed')
    ) if @batch.committed?
  end

end
