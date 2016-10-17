class BatchImportsController < ApplicationController
  include ErrorHandling
  include Sorting

  before_action :set_batch, except: [:help]

  rescue_from ImportFailedError do |e|
    redirect_to new_batch_batch_import_path(@batch), alert: e.message
  end

  # show imports for batch
  def index
    @batch_imports = BatchImport
                         .order(sort_column + ' ' + sort_direction)
                         .page(params[:page])
                         .per(params[:per_page])
                         .where(batch_id: @batch.id)
  end

  # show form to create a new batch import
  def new
    @batch_import = BatchImport.new
    @batch_import.batch = @batch
  end

  # create batch import and queue import job
  def create

    # return error if both fields have data
    raise ImportFailedError.new('You provided both a file and XML text. Choose one only!') if (batch_import_params[:xml].empty? and batch_import_params[:xml_file])
    raise ImportFailedError.new('No file or XML text provided!') unless (batch_import_params[:xml].present? or batch_import_params[:xml_file])

    @batch_import = BatchImport.new

    # copy file contents to string if needed
    if batch_import_params[:xml_file]
      file = batch_import_params[:xml_file]
      if xml.respond_to? :read
        @batch_import.xml = file.read # todo sanitize????
        @batch_import.format = 'file'
      else
        raise ImportFailedError.new('Could not read from uploaded file.')
      end
    else
      @batch_import.xml = batch_import_params[:xml]
      @batch_import.format = 'text'
    end

    @batch_import.user = current_user
    @batch_import.batch = @batch
    @batch_import.validations = run_validations?

    @batch_import.save

    Resque.enqueue(RecordImporter, @batch_import.id)

    respond_to do |format|
      format.html { redirect_to batch_batch_import_path(@batch, @batch_import), notice: 'XML Import Job Queued. This page will show results when the job is finished.' }
    end

  end

  # show info about completed import
  def show
    @batch_import = BatchImport.find(params[:id])
  end

  def destroy
    @batch_import = BatchImport.find(params[:id])
    @batch_import.destroy
    redirect_to batch_batch_imports_path(@batch), notice: 'BatchImport and all associated Batch Items deleted'
  end

  def help
  end

  def xml
    @batch_import = BatchImport.find(params[:id])
  end

  private

  def set_batch
    @batch = Batch.find(params[:batch_id])
  end

  def batch_import_params
    params.require(:batch_import).permit(:xml, :validations)
  end

  def run_validations?
    batch_import_params[:validations] == '1'
  end

end
