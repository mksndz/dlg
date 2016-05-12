class BatchItemImport

  # config
  PRODUCT = 'batch_item'
  TARGET = 'item'
  PARENT = 'collection'

  def initialize(xml, batch, has_parent)
    # receive single xml node
    @batch = batch if batch
    @raw_xml = xml
    begin
      hash = Hash.from_trusted_xml(xml.squish)
    rescue REXML::ParseException
      raise ImportFailedError.new(' : xml invalid')
    end
    @hash = hash[TARGET]
    @replace_id = @hash.delete('id') if @hash['id']
    @parent_slug = @hash.delete(PARENT) if has_parent
  end

  def process
    if @replace_id
      raise ImportFailedError.new(" : Item to replace (ID: #{@replace_id}) could not be found") unless replace_entity_exists_in_meta
      replace
    else
      create_new
    end
    set_additional_attributes
    @batch_item
  end

  private

  def create_new
    @batch_item = PRODUCT.camelize.constantize.new(processed_hash)
  end

  def replace
    @batch_item = PRODUCT.camelize.constantize.new(processed_hash)
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

  def replace_entity_exists_in_meta
    @replace_id && TARGET.camelize.constantize.exists?(@replace_id)
  end

  def permitted_attributes_for entity
    entity.camelize.constantize.column_names
  end

  def processed_hash
    @hash.reject do |k,v|
      permitted_attributes_for(PRODUCT).exclude? k
    end
  end

end