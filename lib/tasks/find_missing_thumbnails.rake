require 'rake'

task :find_missing_thumbnails, [:collection_slug] => [:environment] do |t, args|

  @logger = Logger.new('./log/thumbnail_audit.log')

  start_time = Time.now

  no_thumbs = 0
  new_thumbs = 0

  Item.where(has_thumbnail: false).each do |item|

    # item.has_thumbnail = valid_url? item.thumbnail_url
    # item.save(validate: false)
    # no_thumbs += 1
    # puts "#{no_thumbs} processed"

    if item.has_thumbnail?
      item.has_thumbnail = true;
      item.save(validate: false)
      new_thumbs += 1
    else
      @logger.info 'No Thumbnail found for: ' + item.record_id
      no_thumbs += 1
    end

  end

  finish_time = Time.now

  @logger.info 'complete!'
  @logger.info "Processing took #{finish_time - start_time} seconds!"
  @logger.info "#{new_thumbs} thumbnails set"
  @logger.info "Still #{no_thumbs} thumbnails missing"

end