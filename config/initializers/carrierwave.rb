if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file # in case i switch later
    config.enable_processing = false
  end
end