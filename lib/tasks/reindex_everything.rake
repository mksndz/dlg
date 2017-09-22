require 'rake'

task reindex_everything: :environment do

  @logger = Logger.new('./log/reindex.log')

  INDEXED_MODELS = %W(Item Collection)

  INDEXED_MODELS.each do |model|

    if model.constantize.respond_to? :reindex
      Resque.enqueue(Reindexer, model)
    else
      @logger.warn "#{model} is not configured for indexing"
    end

  end

  puts 'Re-indexing jobs queued.'

end