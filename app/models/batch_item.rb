class BatchItem < ActiveRecord::Base
  include Slugged

  belongs_to :batch
  belongs_to :collection
  has_one :repository, through: :collection

  def title
    dc_title.first
  end

  def self.create_from_xml(xml)

    # todo refactor
    # see http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Reader.html

    hash = Hash.from_trusted_xml xml

    ds = []

    # will only items be imported via xml?
    hash['items'].each do |d,i|
      id = d['id']
      collection_slug = d['collection']['slug']
      d.delete('id')
      d.delete('collection')

      obj = self.new(d)
      # dep, handle in controller?
      obj.collection = Collection.find_by!(slug: collection_slug)
      ds.push obj
    end

    ds

  end

end