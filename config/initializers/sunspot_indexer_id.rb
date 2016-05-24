# for using a different value for the id field of your Solr documents
# only applies when the model has a +record_id+ method available and stored in Solr
Sunspot::Indexer.module_eval do

  alias :old_prepare_full_update :prepare_full_update
  def prepare_full_update(model)
    document = old_prepare_full_update(model)
    if model.respond_to? :record_id
      document.field_by_name(:sunspot_id_ss).value = document.field_by_name(:id).value
      document.field_by_name(:id).value = document.field_by_name(:record_id_ss).value
    end
    document
  end

  # removes item from Solr using the record ID, since we have stored the record in
  # Solr using the Record ID as the ID (see prepare above)
  alias :old_remove :remove
  def remove(*models)
    @connection.delete_by_id(
        models.map do |model|
          model.respond_to?(:record_id) ? model.record_id : model.id
        end
    )
  end

end

# Allows searching with Sunspot's DSL as well to retrieve your models
# copies value from solr field 'sunspot_id_ss' (set in prepare above) to 'id' so
# the default Sunspot functionality will work
class Sunspot::Search::Hit
  def initialize(raw_hit, highlights, search)
    raw_hit['id'] = raw_hit['sunspot_id_ss'] if raw_hit['record_id_ss']
    @class_name, @primary_key = *raw_hit['id'].match(/([^ ]+) (.+)/)[1..2]
    @score = raw_hit['score']
    @search = search
    @stored_values = raw_hit
    @stored_cache = {}
    @highlights = highlights
  end
end