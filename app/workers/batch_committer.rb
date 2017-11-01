# job to commit a given batch
class BatchCommitter
  @queue = :batch_commit_queue
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  def self.perform(batch_id)
    t1 = Time.now
    @batch = batch_for batch_id
    fail_with_message "Batch #{@batch.id} has no BatchItems and will not be committed" unless @batch.batch_items.any?
    notify "Committing Batch `#{@batch.id}` containing `#{@batch.batch_items.count}` items"
    begin
      @batch.commit
    rescue StandardError => e
      fail_with_message "Committing resulted in an error: #{e.message}"
    end
    t2 = Time.now
    notify "Finished committing Batch #{@batch.name} (`#{@batch.id}`). Elapsed time: `#{t2 - t1}` seconds."

  end

  def self.fail_with_message(msg)
    add_job_error msg
    notify msg
  end

  def self.batch_for(batch_id)
    Batch.find batch_id
  rescue ActiveRecord::RecordNotFound
    raise JobFailedError, "Batch with ID #{batch_id} could not be found!"
  end

  def self.notify(msg)
    @slack.ping msg if Rails.env.production?
  end

  def self.add_job_error(msg)
    @batch.job_message = msg
    @batch.queued_for_commit_at = nil
    @batch.save
  end

end