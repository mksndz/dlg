class AddBatchItemCount < ActiveRecord::Migration
  def change

    change_table :batches do |t|
      t.integer :batch_items_count, default: 0
    end

    Batch.reset_column_information

    Batch.all.each do |b|
      Batch.reset_counters(b.id, :batch_items)
    end

  end
end
