# Factory class for creating lots of BatchItems
class BatchItemFactory
  def self.build_from(raw_hashes, validate, batch)
    raw_hashes.map do |raw|
      begin
        hash = ItemHashProcessor.new(raw).process
        bi = BatchItem.new(hash.merge(batch_id: batch.id))
        bi.save! validate: validate
        { record_id: bi.record_id, batch_item: bi }
      rescue StandardError => e
        { record_id: raw.fetch('record_id', 'Unknown'), message: e.message }
      end
    end
  end
end