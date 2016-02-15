class Batch < ActiveRecord::Base

  belongs_to :user

  searchable do

    text :name
    text :notes

    integer :user_id

    time :committed_at
    time :updated_at
    time :created_at

  end

end
