# job to commit a given batch
class BatchCommitter

  @queue = :batch_commit_queue
  @logger = Logger.new('./log/batch_commit.log')

  def self.perform(batch_id)
    batch = validated_batch batch_id
    @logger.info "Committing Batch #{batch.id} with #{batch.batch_items.count}"
    begin
      batch.commit
    rescue StandardError => e
      fail_with_message "Committing resulted in an error: #{e.message}"
    end
    Sunspot.commit_if_dirty
    @logger.info 'Finished committing'
  end

  def self.fail_with_message(msg)
    @logger.error msg
    fail JobFailedError
  end

  def self.validated_batch(batch_id)
    batch = Batch.find batch_id
    fail_with_message "Batch with ID #{batch_id} could not be found." unless batch
    fail_with_message "Batch with ID #{batch_id} could not be committed because it is empty." if batch.batch_items.count < 1
    batch
  end

end