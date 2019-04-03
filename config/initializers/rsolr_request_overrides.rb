# for using a different value for the id field of your Solr documents
# only applies when the model has a +record_id+ method available and stored in Solr
RSolr::Client.module_eval do

  alias :old_build_request :build_request
  # +build_request+ accepts a path and options hash,
  # then prepares a normalized hash to return for sending
  # to a solr connection driver.
  # +build_request+ sets up the uri/query string
  # and converts the +data+ arg to form-urlencoded,
  # if the +data+ arg is a hash.
  # returns a hash with the following keys:
  #   :method
  #   :params
  #   :headers
  #   :data
  #   :uri
  #   :path
  #   :query
  def build_request(path, opts)
    raise "path must be a string or symbol, not #{path.inspect}" unless [String, Symbol].include?(path.class)
    path = path.to_s
    opts[:proxy] = proxy unless proxy.nil?
    opts[:method] ||= :get
    raise "The :data option can only be used if :method => :post" if opts[:method] != :post and opts[:data]
    opts[:params] = params_with_wt(opts[:params])
    # here i need to explicitly not encode a cursorMark param
    cursor_mark = opts[:params].delete(:cursorMark)
    opts[:query] = nil
    unless opts[:params].empty?
      query = RSolr::Uri.params_to_solr(opts[:params])
      query = cursor_mark ? "cursorMark=#{cursor_mark}&#{query}" : query
      opts[:query] = query
    end
    if opts[:data].is_a? Hash
      opts[:data] = RSolr::Uri.params_to_solr opts[:data]
      opts[:headers] ||= {}
      opts[:headers]['Content-Type'] ||= 'application/x-www-form-urlencoded; charset=UTF-8'
    end
    opts[:path] = path
    opts[:uri] = base_uri.merge(path.to_s + (query ? "?#{query}" : "")) if base_uri

    [:open_timeout, :read_timeout, :retry_503, :retry_after_limit].each do |k|
      opts[k] = @options[k]
    end

    opts
  end
end