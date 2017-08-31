# job to commit a given batch
class BatchCommitter
  @queue = :batch_commit_queue
  # @logger = Logger.new('./log/batch_commit.log')
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  def self.perform(batch_id)
    t1 = Time.now
    batch = validated_batch batch_id
    start_msg = "Committing Batch `#{batch.id}` containing `#{batch.batch_items.count}` items"
    # @logger.info start_msg
    notify start_msg
    begin
      batch.commit
    rescue StandardError => e
      fail_with_message "Committing resulted in an error: #{e.message}"
    end
    Sunspot.commit_if_dirty
    t2 = Time.now
    finish_msg = "Finished committing Batch #{batch.name} (`#{batch.id}`). Elapsed time: `#{t2 - t1}` seconds."
    # @logger.info finish_msg
    notify finish_msg
  end

  def self.fail_with_message(msg)
    # @logger.error msg
    notify "Batch commit failed: #{msg}"
    fail JobFailedError
  end

  def self.validated_batch(batch_id)
    batch = Batch.find batch_id
    fail_with_message "Batch with ID `#{batch_id}` could not be found." unless batch
    fail_with_message "Batch with ID `#{batch_id}` could not be committed because it is empty." if batch.batch_items.count < 1
    batch
  end

  def self.notify(msg)
    @slack.ping msg if Rails.env.production?
  end

end