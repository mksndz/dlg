require 'rake'

task reset_validity_cache: :environment do
  start_time = Time.now
  valid = 0
  invalid = 0
  Item.find_each do |item|
    valence = item.valid?
    valence ? valid += 1 : invalid += 1
    item.update_columns valid_item: valence
  end
  puts 'Items complete!'
  puts "Valid: #{valid}"
  puts "Invalid: #{invalid}"
  valid = 0
  invalid = 0
  BatchItem.find_each do |batch_item|
    valence = batch_item.valid?
    valence ? valid += 1 : invalid += 1
    batch_item.update_columns valid_item: valence
  end
  puts 'Batch Items complete!'
  puts "Valid: #{valid}"
  puts "Invalid: #{invalid}"
  finish_time = Time.now
  puts 'Task complete!'
  puts "Processing took #{finish_time - start_time} seconds."
end