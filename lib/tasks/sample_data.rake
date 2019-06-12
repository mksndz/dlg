desc 'Load sample data from db/data directory'

task sample_data: :environment do
  if Repository.any? || Collection.any? || Item.any? || HoldingInstitution.any?
    abort 'Records are already loaded! Exiting.'
  end
  load Rails.root.join 'db', 'data', 'holding_institutions.rb'
  load Rails.root.join 'db', 'data', 'repositories.rb'
  load Rails.root.join 'db', 'data', 'collections.rb'
  load Rails.root.join 'db', 'data', 'items.rb'
  load Rails.root.join 'db', 'data', 'pages.rb'
  Item.reindex
  puts 'Records loaded!'
  Sunspot.commit
end