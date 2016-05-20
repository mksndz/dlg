class AddTimeSpanInterval < ActiveRecord::Migration
  def change
    change_table :time_periods do |t|

      t.rename :end, :finish

      t.timestamp :span

    end
  end
end
