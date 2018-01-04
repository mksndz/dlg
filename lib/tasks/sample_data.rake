desc 'Load sample data from db/data directory'

task sample_data: :environment do
  load File.join(Rails.root, 'db', 'data', 'repositories.rb')
  load File.join(Rails.root, 'db', 'data', 'collections.rb')
  load File.join(Rails.root, 'db', 'data', 'items.rb')
end