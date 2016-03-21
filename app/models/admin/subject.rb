module Admin
  class Subject < ActiveRecord::Base

    has_and_belongs_to_many :collections

    validates_presence_of :name

  end
end