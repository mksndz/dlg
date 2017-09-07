# handles optimization of the solr index
class Optimizer
  @queue = :optimize
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  def self.perform
    t1 = Time.now
    @slack.ping 'Solr optimize starting'
    Sunspot.optimize
    elapsed = Time.now - t1
    @slack.ping("Solr optimize completed in #{elapsed} seconds")
  end

end