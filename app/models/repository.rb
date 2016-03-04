class Repository < ActiveRecord::Base
  include Slugged

  has_many :collections, dependent: :destroy
  has_many :items, through: :collections
  has_and_belongs_to_many :users

  validates_presence_of :title

end