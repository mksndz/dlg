module Meta
  class ItemSearch
    def self.search(q)
      page = q.delete(:page) || 1
      per_page = q.delete(:per_page) || 10

      # Sanitize the rest of the fields
      q = sanitize_fields(q)

      s = Item.search do
        # todo repo and collection limits
        with :dpla, q[:dpla] unless q[:dpla].empty?
        with :public, q[:public] unless q[:public].empty?
        fulltext q[:keyword].empty? ? '*' : q[:keyword]
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