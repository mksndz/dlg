Geocoder.configure(
  timeout: 3,
  opencagedata: {
    api_key: Rails.application.secrets.opencage_api_key,
  },
  nominatim: {
    http_headers: {
      'User-Agent' => "Digital Library of Georgia (#{Rails.application.secrets.nominatim_contact})"
    }
  },
  use_https: true,
  cache: @redis,
  cache_prefix: 'geocoder:'
)
