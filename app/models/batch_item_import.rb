class BatchItemImport

  # config
  PRODUCT = 'batch_item'
  TARGET = 'item'
  PARENT = 'collection'

  def initialize(xml, batch, has_parent)
    # receive single xml node
    @batch = batch if batch
    @raw_xml = xml
    hash = Hash.from_trusted_xml(xml.squish)
    @hash = hash[TARGET]
    @replace_id = @hash.delete('id') if @hash['id']
    @parent_slug = @hash.delete(PARENT) if has_parent
  end

  def process
    entity_exists_in_meta ? replace : create_new
    set_additional_attributes
    throw ImportFailedError unless @batch_item
    @batch_item
  end

  private

  def create_new
    @batch_item = PRODUCT.camelize.constantize.new(@hash)
  end

  def replace
    @batch_item = PRODUCT.camelize.constantize.new(@hash)
    target = TARGET.camelize.constantize.find(@replace_id)
    @batch_item["#{TARGET}_id".to_sym] = target.id
  end

  def set_additional_attributes
    @batch_item.batch = @batch if @batch
    if @parent_slug
      parent = PARENT.camelize.constantize.find_by_slug(@parent_slug['slug'])
      @batch_item["#{PARENT}_id".to_sym] = parent.id
    end
  end

  def entity_exists_in_meta
    return false unless @replace_id
    TARGET.camelize.constantize.exists? @replace_id
  end

end