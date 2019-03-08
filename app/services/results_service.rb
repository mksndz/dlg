# for any object with a #results field as JSON...
class ResultsService

  def initialize(job:)
    @job = job
    @added = []
    @failed = []
    @updated = []
  end

  def error(id, message)
    @failed << { id: id, message: message }
  end

  # def success(id, message)
  #   @added << { id: id, message: message}
  # end

  def finalize
    @job.results = results
  end

  private

  def results
    {
      added: @added,
      updated: @updated,
      failed: @failed
    }
  end
end