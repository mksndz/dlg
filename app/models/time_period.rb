class TimePeriod < ActiveRecord::Base

  has_and_belongs_to_many :collections

  validates_presence_of :name

  searchable do

    string :name, stored: true

  end

end
