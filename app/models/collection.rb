class Collection < ActiveRecord::Base

  has_many :items, dependent: :destroy, counter_cache: true
  has_many :public_items, -> { where public: true }, class_name: 'Item'
  has_many :dpla_items, -> { where dpla: true }, class_name: 'Item'
  belongs_to :repository

end
