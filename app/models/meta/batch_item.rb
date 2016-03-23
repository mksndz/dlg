module Meta
  class BatchItem < ActiveRecord::Base
    include Slugged

    belongs_to :batch
    belongs_to :collection
    has_one :repository, through: :collection

    validates_presence_of :collection, message: ' could not be set'

    def title
      dc_title.first
    end

    def self.create_from_xml(xml)

      # receive single xml node

      data_hash = Hash.from_trusted_xml xml

      return false unless data_hash

      object = data_hash['item']

      return false unless object

      parent_slug = object['collection']['slug'] # hmm

      object.delete('id') # delete ID node so AR sets ID
      object.delete('collection') # delete collection slug so we can set that association

      return {
          batch_item:   self.new(object),
          parent_slug:  parent_slug # hmm
      }

    end

  end
end
