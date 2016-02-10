class Repository < ActiveRecord::Base
  include Slugged

  has_many :collections, dependent: :destroy
  has_many :items, through: :collections

  validates_presence_of :title

end