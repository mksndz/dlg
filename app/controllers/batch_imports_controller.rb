class BatchImportsController < ApplicationController

  before_action :set_batch

  # show imports for batch
  def index



  end

  # show form to create a new batch import
  def new



  end

  # create batch import and queue import job
  def create



  end

  # show info about completed import
  def show



  end

  private

  def set_batch
    @batch = Batch.find(params[:batch_id])
  end

end
