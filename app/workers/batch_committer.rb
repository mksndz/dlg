# job to commit a given batch
class BatchCommitter
  @queue = :batch_commit_queue
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  def self.perform(batch_id)
    t1 = Time.now
    @batch = batch_for batch_id
    unless @batch.batch_items.any?
      note_failure "Batch #{@batch.id} has no BatchItems and will not be committed"
      return
    end
    notify "Committing `#{@batch.name}` with `#{@batch.batch_items.count}` items."
    begin
      @batch.commit
    rescue StandardError => e
      note_failure "Committing resulted in an error: #{e.message}"
    else
      t2 = Time.now
      notify "Commit finished for `#{@batch.name}` in `#{t2 - t1}` seconds."
    end
  end

  def self.note_failure(msg)
    add_job_error msg
    notify msg
  end

  def self.batch_for(batch_id)
    Batch.find batch_id
  rescue ActiveRecord::RecordNotFound
    raise JobFailedError, "Batch with ID #{batch_id} could not be found!"
  end

  def self.notify(msg)
    @slack.ping msg if Rails.env.production? || Rails.env.staging?
  end

  def self.add_job_error(msg)
    @batch.job_message = msg
    @batch.queued_for_commit_at = nil
    @batch.save
  end

end