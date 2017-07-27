# handles reindexing of models or objects
class Reindexer

  @queue = :reindex
  @logger = Logger.new('./log/reindex.log')

  REINDEX_BATCH_SIZE = 1000

  def self.perform(model, ids = [])
    @model = model
    start_time = Time.now
    ids ? reindex_objects(ids) : reindex_model
    end_time = Time.now
    @logger.info "Reindexing of #{model} complete! Job took #{end_time - start_time} seconds."
  end

  def self.reindex_model
    @logger.info "Reindexing entire all #{model} objects."
    @model.constantize.find_in_batches(batch_size: REINDEX_BATCH_SIZE) do |batch|
      Sunspot.index! batch
    end
  rescue StandardError => e
    @logger.fatal "Reindexing failed for model #{model}: #{e}"
  end

  def self.reindex_objects(object_ids)
    @logger.info "Reindexing selected objects from #{@model}."
    @model.constantize.where(id: object_ids).find_in_batches(batch_size: REINDEX_BATCH_SIZE) do |batch|
      Sunspot.index! batch
    end
  rescue StandardError => e
    @logger.fatal "Reindexing failed for model #{@model} with object_ids: #{e}"
  end

end