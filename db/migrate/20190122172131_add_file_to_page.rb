# support file uploads to Page

class AddFileToPage < ActiveRecord::Migration
  def change
    change_table :pages do |t|
      t.string :file
    end
  end
end
