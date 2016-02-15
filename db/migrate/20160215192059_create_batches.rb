class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|

      t.integer   :user_id,     null: false
      t.index     :user_id
      t.integer   :contained_count
      t.string    :name,        null: false, uniqueness: true
      t.text      :notes
      t.datetime  :committed_at

      t.timestamps              null: false

    end
  end


end
