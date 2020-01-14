# frozen_string_literal: true

# :nodoc:
class AddRemediationAction < ActiveRecord::Migration
  def change
    create_table :remediation_actions do |t|
      t.string :field
      t.string :old_text
      t.string :new_text
      t.references :user
      t.integer :items, array: true, default: []
      t.datetime :performed_at
      t.timestamps
    end
  end
end
