module Meta
  class Batch < ActiveRecord::Base

    belongs_to :admin
    has_many :batch_items, dependent: :destroy

    validates_presence_of :admin, :name

    searchable do

      text :name
      text :notes

      integer :admin_id

      time :committed_at
      time :updated_at
      time :created_at

    end

    def committed?
      !!committed_at
    end

  end
end

