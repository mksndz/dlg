require 'rake'

task import_collection_items: :environment do

  @logger = Logger.new('./log/item_import.log')

  meta_xml_root_url = 'http://dlg.galileo.usg.edu/xml/dcq/'.freeze

  unless Repository.first
    @logger.error 'No Repositories yet in the system!'
    abort
  end

  unless Collection.first
    @logger.error 'No Collections yet in the system!'
    abort
  end

  puts 'Enter number of Collections to populate, or leave blank for all: '
  number = STDIN.gets.chomp

  if number != ''
    Collection.first(number).each do |c|
      Resque.enqueue(
          CollectionImporter, c.id, "#{meta_xml_root_url}#{c.record_id}.xml"
      )
    end
    puts "Import jobs for the first #{number} collections added to items queue."
  else
    Collection.find_each(batch_size: 100) do |c|
      Resque.enqueue(
          CollectionImporter, c.id, "#{meta_xml_root_url}#{c.record_id}.xml"
      )
    end
    puts 'Import jobs for all collections added to items queue.'
  end

end