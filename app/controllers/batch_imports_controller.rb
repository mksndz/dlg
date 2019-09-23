# controller actions for batch imports
class BatchImportsController < ApplicationController
  authorize_resource
  include ErrorHandling
  include Sorting
  before_action :set_batch, except: [:help]
  before_action :set_batch_import, except: %i[index new create help]
  before_action :ensure_uncommitted_batch, except: %i[index show xml help]

  rescue_from ImportFailedError do |e|
    redirect_to new_batch_batch_import_path(@batch), alert: e.message
  end

  rescue_from BatchCommittedError do |e|
    redirect_to batch_batch_imports_path(@batch), alert: e.message
  end

  # show imports for batch
  def index
    @batch_imports = BatchImport.where(batch_id: @batch.id)
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

    if batch_import_params[:text].present? && file
      raise(
        ImportFailedError,
        I18n.t('meta.batch_import.messages.errors.both_types')
      )
    end

    @batch_import = BatchImport.new

    # copy file contents to string if needed
    if file
      if file.respond_to? :read
        @batch_import.xml = file.read # TODO: sanitize xml input
        @batch_import.format = 'file'
        @batch_import.file_name = file.original_filename
      else
        raise(
          ImportFailedError,
          I18n.t('meta.batch_import.messages.errors.file_error')
        )
      end
    elsif text && !text.empty?
      @batch_import.xml = batch_import_params[:xml].strip
      @batch_import.format = 'text'
    elsif ids
      @batch_import.item_ids = ids.split(',')
      @batch_import.format = 'search query'
    else
      raise(
        ImportFailedError,
        I18n.t('meta.batch_import.messages.errors.no_data')
      )
    end

    @batch_import.user = current_user
    @batch_import.batch = @batch
    @batch_import.validations = run_validations?
    @batch_import.match_on_id = match_on_id?

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

  def show; end

  def destroy
    @batch_import.destroy
    redirect_to batch_batch_imports_path(@batch), notice: I18n.t('meta.batch_import.messages.success.deleted')
  end

  def help; end

  def xml; end

  private

  def set_batch
    @batch = Batch.find(params[:batch_id])
  end

  def set_batch_import
    @batch_import = BatchImport.find params[:id]
  end

  def batch_import_params
    params.require(:batch_import).permit(
      :xml,
      :xml_file,
      :validations,
      :match_on_id,
      :item_ids
    )
  end

  def run_validations?
    batch_import_params[:validations] == '1'
  end

  def match_on_id?
    batch_import_params[:match_on_id] == '1'
  end

  def ensure_uncommitted_batch
    return true unless @batch.committed?

    raise(
      BatchCommittedError,
      I18n.t('meta.batch.messages.errors.batch_already_committed')
    )
  end
end
