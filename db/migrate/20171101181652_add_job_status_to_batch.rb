class AddJobStatusToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :job_message, :string
  end
end
