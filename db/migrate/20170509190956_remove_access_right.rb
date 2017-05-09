# removes unneeded DCQ field from collection schema
class RemoveAccessRight < ActiveRecord::Migration
  def change
    change_table :collections do |t|
      t.remove :dcterms_access_right
    end
  end
end
