module IndexFilterable
  extend ActiveSupport::Concern
  included do
    def self.index_query(params)
      options = {}
      if params.present?
        index_query_fields.each do |f|
          options[f] = params[f] if params[f] && !params[f].empty?
        end
      end
      options.present? ? where(options) : all
    end

    def self.index_query_fields
      INDEX_QUERY_FIELDS
    end
  end
end