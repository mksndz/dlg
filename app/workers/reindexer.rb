class Reindexer

  @queue = :reindex
  @logger = Logger.new('./log/reindex.log')

  def self.perform(model)

    @logger.info "Reindexing #{model}"
    model_start_time = Time.now
    begin
      model.constantize.reindex
    rescue StandardError => e
      @logger.fatal "Reindexing #{model} failed: #{e}"
    end
    model_finish_time = Time.now
    @logger.info "#{model} re-indexed in #{model_finish_time - model_start_time} seconds"

  end


end