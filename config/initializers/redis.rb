host = Rails.application.secrets.try(:redis_host) || 'localhost'
$redis = Redis.new(host: host, port: 6379)