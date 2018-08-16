class Project < ActiveRecord::Base
  belongs_to :holding_institution
  has_and_belongs_to_many :collections
end
