require 'rake'

task expunge_meta_entities: :environment do

  puts "This task will destroy all Repository, Collection, Item, Batch and Batch Item records.\n"
  puts "It will also delete Bookmarks and Collection and Repository assignments to Users.\n"
  puts "It will not delete User records.\n"
  puts "Are you sure you want to do this? Type 'Y' to confirm: "

  answer = STDIN.gets.chomp

  unless answer.downcase == 'y'
    puts 'Task cancelled.'
    abort
  end

  def truncate_table(table_name)
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name} RESTART IDENTITY CASCADE;")
  end

  [ItemVersion, BatchItem, Item, Batch, Collection, Repository].each do |t|
    truncate_table t.table_name
  end

  %w(collections_users repositories_users collections_subjects bookmarks).each do |t|
    truncate_table t
  end

  puts 'Entities expunged!'

end