class RenameHoldingInstType < ActiveRecord::Migration
  def change
    change_table :holding_institutions do |t|
      t.rename :type, :institution_type
    end
  end
end
