require 'rake'

task :clean_all_items, [:dry_run] => :environment do |t, args|
  start_time = Time.now
  dry_run = args[:dry_run]
  logger = Logger.new('./log/cleaner_changes.log')
  cleaner = MetadataCleaner.new
  Item.all.in_batches(of: 1000).each_record do |item|
    cleaner.clean item
    if item.changed?
      logger.info "Item #{item.id} Cleaned!\n #{item.changes.map { |k, v| "#{k}: #{v}"}.join("\n")}"
      item.save unless dry_run
    end
  end
  finish_time = Time.now
  puts 'Cleaning complete!'
  puts "Cleaning took #{finish_time - start_time} seconds!"
  puts 'Review log and reindex all Items'
end