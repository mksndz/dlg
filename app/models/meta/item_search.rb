module Meta
  class ItemSearch
    def self.search(q)
      page = q.delete(:page) || 1
      per_page = q.delete(:per_page) || 10
      pp = {}
      keyword = q[:keyword] || '*'
      keyword = keyword == '' ? '*' : keyword
      pp[:dpla] = !!q[:dpla] unless q[:dpla] == ''
      pp[:public] = !!q[:public] unless q[:public] == ''
      pp[:collection_id] = q[:collection_id] unless q[:collection_id] == ''
      pp[:repository_id] = q[:repository_id] unless q[:repository_id] == ''

      # Sanitize the rest of the fields
      q = sanitize_fields(q)

      s = Item.search do
        fulltext keyword
        all_of do
          pp.each { |k,v| with(k, v) }
        end
        paginate page: page, per_page: per_page
      end

      s.results
    end

    private

    def self.sanitize_fields(q)
      whitelisted_fields = Sunspot::Setup.for(Item).fields.map(&:name)
      whitelisted_fields.push(:page, :per_page, :keyword)
      q.slice(*whitelisted_fields).with_indifferent_access
    end

  end
end