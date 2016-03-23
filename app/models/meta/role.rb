module Meta
  class Role < ActiveRecord::Base

    has_and_belongs_to_many :admins

    validates_presence_of :name

  end
end

