# frozen_string_literal: true

# remove some old legacy fields from Collection
class RemoveLegacyCollectionFields < ActiveRecord::Migration
  def change
    change_table :collections do |t|
      t.remove :in_georgia
      t.remove :color
    end
  end
end
