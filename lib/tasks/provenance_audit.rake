require 'rake'

task provenance_audit: :environment do |t, args|
  logger = Logger.new('./log/provenance_audit.log')
  Item.all.find_each do |i|
    legacy = i.legacy_dcterms_provenance
    newnew = i.holding_institution_names
    if legacy != newnew
      logger.warn "Mismatch on #{i.record_id}: \n Legacy: #{legacy}\n New:   #{newnew}"
    end
  end
end