class Collection < ActiveRecord::Base
  include Slugged
  include SolrIndexing

  has_many :items, dependent: :destroy
  has_many :public_items, -> { where public: true }, class_name: 'Item'
  has_many :dpla_items, -> { where dpla: true }, class_name: 'Item'
  belongs_to :repository

  validates_presence_of :display_title

  def title
    dc_title.first
  end

end
