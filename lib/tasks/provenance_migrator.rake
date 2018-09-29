require 'rake'

task :provenance_migrator, [:collection_record_id] => :environment do |t, args|
  start_time = Time.now
  collection_record_id = args[:collection_record_id]
  logger = Logger.new('./log/provenance_migrator.log')
  collection = Collection.find_by_record_id collection_record_id
  unless collection
    logger.error "No Collection with record ID #{collection_record_id}"
    next
  end
  collection.items.find_each do |i|
    i.legacy_dcterms_provenance.each do |lp|
      hi = HoldingInstitution.find_by_display_name lp
      unless hi
        logger.warn "No Holding Institution for #{lp} in Collection #{collection_record_id}"
        next
      end
      i.holding_institutions << hi
      i.save(validate: false)
    end
  end
  Sunspot.commit
  finish_time = Time.now
  puts "Migration complete for #{collection_record_id} in #{finish_time - start_time} seconds"
end