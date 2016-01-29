# for using a different value for the id field of your Solr documents
Sunspot::Indexer.module_eval do

  # define models
  SLUGGED_MODELS = [Repository, Collection, Item]

  alias :old_prepare_full_update :prepare_full_update
  def prepare_full_update(model)
    document = old_prepare_full_update(model)
    if SLUGGED_MODELS.include? model.class
      document.field_by_name(:sunspot_id_s).value = document.field_by_name(:id).value
      document.field_by_name(:id).value = document.field_by_name(:slug_s).value
    end
    document
  end

  # removes item from Solr using the slug, since we have stored the record in
  # Solr using the Slug as the ID (see prepare above)
  alias :old_remove :remove
  def remove(*models)
    @connection.delete_by_id(
        models.map do |model|
          SLUGGED_MODELS.include? model.class ? model.slug : model.id
        end
    )
  end

end

# Allows searching with Sunspot's DSL as well to retrieve your models
# copies value from solr field 'sunspot_id_s' (set in prepare above) to 'id' so
# the default Sunspot functionality will work
class Sunspot::Search::Hit
  def initialize(raw_hit, highlights, search)
    raw_hit['id'] = raw_hit['sunspot_id_s'] if SLUGGED_MODELS.include? raw_hit['class_name'].first
    @class_name, @primary_key = *raw_hit['id'].match(/([^ ]+) (.+)/)[1..2]
    @score = raw_hit['score']
    @search = search
    @stored_values = raw_hit
    @stored_cache = {}
    @highlights = highlights
  end
end