require 'rake'

task audit_solr: :environment do

  logger = Logger.new('solr_audit_log.log')
  
  total_items_in_db = 0
  total_items_in_solr = 0

  Collection.all.each do |c|

    s = Item.search do
      with(:collection_id, c.id)

      adjust_solr_params do |params|
        params[:q] = ''
      end
    end

    total_items_in_db += c.items_count
    total_items_in_solr += s.total

    if total_items_in_db > total_items_in_solr
      logger.info "Collection #{c.slug} has #{s.total} records in Solr but #{c.items_count}. #{s.total - c.items_count} are missing :/"
    else
      logger.info "Collection #{c.slug} is OK"
    end

    solr_slugs = solr_slugs_array s
    db_slugs = db_slugs_array c

    missing_item_slugs = db_slugs - solr_slugs

    unless missing_item_slugs.empty?
      logger.info "Missing Item slugs: #{missing_item_slugs.inspect}"
    end

  end

  logger.info "Total Items in DB: #{total_items_in_db}"
  logger.info "Total Items in Solr: #{total_items_in_solr}"
  logger.info "Missing Items: #{total_items_in_db - total_items_in_solr}"

  private

  def solr_slugs_array(search)
    search.hits.map do |hit|
      hit.stored :slug
    end
  end

  def db_slugs_array(collection)
    collection.pluck :slug
  end

end