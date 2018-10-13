class AlterNameFieldsOnHoldingInst < ActiveRecord::Migration
  def change
    change_table :holding_institutions do |t|
      t.rename :display_name, :authorized_name
      t.string :display_name
    end
  end
end
