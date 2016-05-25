require 'rake'

task :all_items, [:collection_slug] => [:environment] do |t, args|

  @logger = Logger.new('./log/all_items.log')

  def exit_with_error(msg = nil)
    @logger.info msg || 'Something unexpected happened...'
    abort
  end

  def get_solr_hits_for_collection(collection)
    s = Item.search do
      with(:collection_id, collection.id)

      adjust_solr_params do |params|
        params[:q] = ''
      end
    end
    s.total
  end

  start_time = Time.now

  # if defined?(args) && args[:collection_slug]
  #   collection = Collection.find_by_slug(args[:collection_slug])
  #   if collection
  #     collections = [collection]
  #     @logger.info "Designated Collection to load: #{collections.first.slug}"
  #   else
  #     exit_with_error('Error loading the Collection you specified')
  #   end
  # else
  #   collections = Collection.all
  # end

  s = Item.search do
    adjust_solr_params do |params|
      params[:q] = ''
    end
  end

  # report on most common fields with data
  pages = s.results.total_pages
  items = s.total
  counter = 0

  # loop through all items
  (1..pages).each do |i|

    ss = Item.search do
      adjust_solr_params do |params|
        params[:q] = ''
        paginate page: i
      end
    end

    ss.hits.each do |hit|
      counter += 1
      @logger.info counter
      @logger.info hit.inspect

    end

    @logger.info "#{counter} items"
    @logger.info "page #{i} complete"

  end

  @logger.info "#{items} total"
  @logger.info "#{Item.all.length} in DB"

  finish_time = Time.now

  @logger.info 'complete!'
  @logger.info "Processing took #{finish_time - start_time} seconds!"

end