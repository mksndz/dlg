class BatchImportsController < ApplicationController
  include ErrorHandling

  before_action :set_batch

  rescue_from ImportFailedError do |e|
    redirect_to :new, alert: e.message
  end

  # show imports for batch
  def index
    @batch_imports = BatchImport
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
    throw ImportFailedError('You provided both a file and XML text. Choose one only!') if (batch_import_params[:xml] and batch_import_params[:xml_file])

    # copy file contents to string if needed
    if batch_import_params[:xml_file]
      file = batch_import_params[:xml_file]
      if xml.respond_to? :read
        xml = file.read
      else
        throw ImportFailedError('Could not read from uploaded file.')
      end
    else
      xml = batch_import_params[:xml]
    end

    @batch_import = BatchImport.new
    @batch_import.xml = xml
    @batch_import.batch = @batch

    # save entity
    @batch_import.save

    # queue processing job
    Resque.enqueue(
        RecordImporter(@batch_import)
    )

    # return
    respond_to do |format|
      format.html { redirect_to batch_batch_import_path(@batch) }
    end

  end

  # show info about completed import
  def show
  end

  def help
  end

  private

  def set_batch
    @batch = Batch.find(params[:batch_id])
  end

  def batch_import_params
    params.require(:batch_import).permit(:xml, :bypass_validations)
  end

end
