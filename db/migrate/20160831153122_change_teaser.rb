class ChangeTeaser < ActiveRecord::Migration
  def change

    change_table :collections do |t|
      t.remove :teaser
    end

    change_table :repositories do |t|
      t.remove :teaser
      t.boolean :teaser
    end

  end
end
