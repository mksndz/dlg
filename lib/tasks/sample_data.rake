desc 'Load sample data from db/data directory'

task sample_data: :environment do
  if Repository.any? || Collection.any? || Item.any? || HoldingInstitution.any?
    abort 'Records are already loaded! Exiting.'
  end
  load File.join(Rails.root, 'db', 'data', 'holding_institutions.rb')
  load File.join(Rails.root, 'db', 'data', 'repositories.rb')
  load File.join(Rails.root, 'db', 'data', 'collections.rb')
  load File.join(Rails.root, 'db', 'data', 'items.rb')
  puts 'Records loaded!'
  Sunspot.commit
end