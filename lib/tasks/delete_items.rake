require 'rake'
require 'csv'

task :delete_items, [:file_path] => :environment do |_, args|
  unless defined?(args) && args[:file_path]
    puts 'No file specified'
    return
  end
  record_ids = CSV.read args[:file_path]
  record_ids.each do |record_id|
    record_id = record_id[0] if record_id.is_a? Array
    record_id = record_id[0] if record_id.is_a? Array
    item = Item.find_by_record_id record_id.strip
    unless item
      puts "Cannot find Item with record_id #{record_id}"
      next
    end
    item.destroy
  end
  Sunspot.commit
  puts "Items listed in #{args[:file_path]} destroyed"
end