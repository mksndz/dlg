# frozen_string_literal: true

# facilitate the sending of (slack) notifications
class NotificationService

  NOTIFICATION_ENVIRONMENTS = %w[production staging].freeze

  def initialize
    @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook
  end

  # send a basic notification
  def notify(message)
    @slack.ping(message) if NOTIFICATION_ENVIRONMENTS.include? Rails.env
  end
end