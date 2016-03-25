module Meta
  class ItemSearch
    def self.search(q)
      page = q.delete(:page) || 1
      per_page = q.delete(:per_page) || 10
      keyword = q[:keyword] || '*'
      keyword = keyword == '' ? '*' : keyword
      terms = {
        dpla: get_form_boolean(q[:dpla]),
        public: get_form_boolean(q[:public]),
        collection_id: get_form_val(q[:collection_id]),
        repository_id: get_form_val(q[:repository_id])
      }

      s = Item.search do
        fulltext keyword
        all_of do
          terms.each { |k,v| with(k, v) if v }
        end
        paginate page: page, per_page: per_page
      end

      s.results
    end

    private

    def self.get_form_boolean(form_val)
      form_val.to_i == 1 unless form_val ==''
    end

    def self.get_form_val(form_val)
      form_val unless form_val ==''
    end

  end
end