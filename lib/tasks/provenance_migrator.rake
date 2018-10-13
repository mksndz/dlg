require 'rake'

task provenance_migrator: :environment do |t, args|
  logger = Logger.new('./log/provenance_migrator.log')
  Collection.all.each do |collection|
    catch :already_done do
      start_time = Time.now
      collection.items.find_each do |i|
        if i.holding_institutions.any?
          logger.error "Item #{i.record_id} in #{collection.record_id} already has HI values! Skipping Collection"
          throw :already_done
        end
        i.legacy_dcterms_provenance.each do |lp|
          hi = HoldingInstitution.find_by_authorized_name lp
          unless hi
            logger.warn "No Holding Institution for #{lp} in Collection #{collection.record_id}"
            next
          end
          i.holding_institutions << hi
          i.save(validate: false)
        end
      end
      Sunspot.commit
      finish_time = Time.now
      logger.info "Migration complete for #{collection.record_id} in #{finish_time - start_time} seconds"
    end
  end
  logger.info 'All Collections finished'
end