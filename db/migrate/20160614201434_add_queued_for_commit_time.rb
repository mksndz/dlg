class AddQueuedForCommitTime < ActiveRecord::Migration
  def change
    change_table :batches do |t|
      t.datetime  :queued_for_commit_at
    end
  end
end
