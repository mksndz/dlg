require 'rake'

task provenance_audit: :environment do |t, args|
  logger = Logger.new('./log/provenance_audit.log')
  n = 0
  Item.all.find_each do |i|
    n += 1
    legacy = i.legacy_dcterms_provenance
    newnew = i.holding_institution_names
    if legacy.sort != newnew.sort
      logger.warn "Mismatch on #{i.record_id}: \n Legacy: #{legacy}\n New:   #{newnew}"
    end
    if newnew.uniq != newnew
      logger.warn "Removing duplicate HI for #{i.record_id}: #{newnew}"
      i.holding_institution_ids = i.holding_institution_ids.uniq
    end
    if legacy.empty? && newnew.empty?
      logger.warn "No HI values anywhere for #{i.record_id}"
    end
    puts n
  end
end