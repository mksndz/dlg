class Reindexer

  @queue = :reindex
  @logger = Logger.new('./log/reindex.log')

  REINDEX_BATCH_SIZE = 1000

  def self.perform(model)

    @logger.info "Reindexing #{model}"
    model_start_time = Time.now
    begin
      model.constantize.find_in_batches(batch_size: REINDEX_BATCH_SIZE) do |batch|
        Sunspot.index batch
        Sunspot.commit
      end
    rescue StandardError => e
      @logger.fatal "Reindexing #{model} failed: #{e}"
    end

    model_finish_time = Time.now
    @logger.info "#{model} re-indexed in #{model_finish_time - model_start_time} seconds"

  end


end