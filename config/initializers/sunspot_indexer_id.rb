# for using a different value for the id field of your Solr documents
Sunspot::Indexer.module_eval do

  alias :old_prepare_full_update :prepare_full_update
  def prepare_full_update(model)
    document = old_prepare_full_update(model)
    document.add_field(:resource_id_ss, document.field_by_name(:id).value)
    unless document.field_by_name(:slug_s).blank?
      document.field_by_name(:id).value = document.field_by_name(:slug_s).value
    end
    document
  end

  # TODO test, fix
  alias :old_remove :remove
  def remove(*models)
    @connection.delete_by_id(
        models.map do |model|
          prepare(model).fields_by_name(:id).first.value
        end
    )
  end

end

# to allow searching with Sunspot's DSL as well to retrieve your models
class Sunspot::Search::Hit # TODO test
  def initialize(raw_hit, highlights, search)
    raw_hit['id'] = raw_hit['resource_id_ss']
    @class_name, @primary_key = *raw_hit['id'].match(/([^ ]+) (.+)/)[1..2]
    @score = raw_hit['score']
    @search = search
    @stored_values = raw_hit
    @stored_cache = {}
    @highlights = highlights
  end
end