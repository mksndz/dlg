class Batch < ActiveRecord::Base

  belongs_to :user
  has_many :batch_items, table_name: 'items', counter_cache: true

  searchable do

    text :name
    text :notes

    integer :user_id

    time :committed_at
    time :updated_at
    time :created_at

  end

  def committed?
    !!committed_at
  end

end
