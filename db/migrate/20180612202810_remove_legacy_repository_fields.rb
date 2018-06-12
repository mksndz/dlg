# frozen_string_literal: true

# remove some old legacy fields from Repo
class RemoveLegacyRepositoryFields < ActiveRecord::Migration
  def change
    change_table :repositories do |t|
      t.remove :color
      t.remove :in_georgia
    end
  end
end
