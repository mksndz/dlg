class Repository < ActiveRecord::Base

  has_many :collections, dependent: :destroy
  has_many :public_collections, -> { where public: true }, class_name: 'Collection'
  has_many :dpla_collections, -> { where dpla: true }, class_name: 'Collection'
  has_many :items, through: :collections

end
