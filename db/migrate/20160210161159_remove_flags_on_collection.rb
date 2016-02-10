class RemoveFlagsOnCollection < ActiveRecord::Migration
  def change

    change_table :collections do |t|

      t.remove :dpla
      t.remove :public

    end

  end
end
