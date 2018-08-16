class Project < ActiveRecord::Base
  has_one :holding_institution
  has_many :collections
end
