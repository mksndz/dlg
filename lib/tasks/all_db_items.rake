require 'rake'

task :all_db_items, [:collection_slug] => [:environment] do |t, args|

  @logger = Logger.new('./log/all_db_items.log')

  start_time = Time.now

  Item.all.each do |item|


  end

  finish_time = Time.now

  @logger.info 'complete!'
  @logger.info "Processing took #{finish_time - start_time} seconds!"

end