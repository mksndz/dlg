# handles re-saving (and reindexing) or large batch of Items
class Resaver

  @queue = :resave
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  RESAVE_BATCH_SIZE = 100

  def self.perform(item_ids = [])
    return unless item_ids.any?
    start_time = Time.now
    count = item_ids.length
    Item.where(id: item_ids).find_each(batch_size: RESAVE_BATCH_SIZE) do |i|
      i.save(validate: false)
    end
    end_time = Time.now
    end_message = "`#{count}` #{'Item'.pluralize(count)} from `#{Item.find(item_ids.last).collection.slug}` re-saved in `#{end_time - start_time}` seconds."
    notify end_message
  end

  def self.notify(message)
    @slack.ping(message) if Rails.env.production?
  end

end