class BatchCommitter

  @queue = :batch_commit_queue
  @logger = Logger.new('./log/batch_commit.log')

  def self.perform(batch_id)

    b = Batch.find batch_id

    unless b
      @logger.error "Batch with ID #{batch_id} could not be found."
      raise JobFailedError
    end

    if b.batch_items.count < 1
      @logger.error "Batch with ID #{batch_id} could not be committed because it is empty."
      raise JobFailedError
    end

    @logger.info "Committing Batch #{b.id} with #{b.batch_items.count}"

    begin
      b.commit
    rescue => e
      @logger.error "Committing resulted in an error: #{e.message}"

    end

    Sunspot.commit_if_dirty

    @logger.info 'Finished committing'

  end

end