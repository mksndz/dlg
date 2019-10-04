require 'exception_notification/rails'
require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'exception_notification/resque'

Resque::Failure::Multiple.classes = [Resque::Failure::Redis, ExceptionNotification::Resque]
Resque::Failure.backend = Resque::Failure::Multiple


ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, Mongoid::Errors::DocumentNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
  config.ignore_if do |_, _|
    Rails.env.test? || Rails.env.development?
  end

  config.add_notifier :slack,
                      webhook_url: Rails.application.secrets.slack_worker_webhook,
                      channel: '#app-exceptions',
                      username: 'dlg-admin',
                      additional_parameters: {
                        icon_emoji: ':boom:',
                        mrkdwn: true
                      }
end
