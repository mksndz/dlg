require 'rake'

task audit_portal_hierarchies: :environment do
  logger = Logger.new './log/portal_audit.log'
  logger.info "Audit Run: #{Time.now}"
  # Check downward relations for Repositories
  Repository.all.each do |r|
    repository_portal_ids = r.portal_ids
    Collection.where(repository_id: r.id) do |c|
      # check if collection has a Portal assignment not in Rep
      collection_portal_ids = c.portal_ids
      diff = collection_portal_ids - repository_portal_ids
      if diff.any?
        msg = "Collection #{cid} (#{c.display_title}) has a Portal not "\
              "assigned to its parent: #{diff.join(', ')}"
        logger.info msg
      end
    end
  end
  # Check downward relations for Collections
  Collection.all.each do |c|
    collection_portal_ids = c.portal_ids
    Item.where(collection_id: c.id).find_in_batches(batch_size: 500) do |items|
      items.each do |i|
        item_portal_ids = i.portal_ids
        diff = item_portal_ids - collection_portal_ids
        if diff.any?
          msg = "Item #{c.id} (#{i.record_id}) has a Portal not assigned "\
              "to its parent: #{diff.join(', ')}"
          logger.info msg
        end
      end
    end
  end
  logger.info "Audit Complete: #{Time.now}"
end