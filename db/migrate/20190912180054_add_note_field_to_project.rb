# frozen_string_literal: true

# add note field to project
class AddNoteFieldToProject < ActiveRecord::Migration
  def change
    add_column :projects, :notes, :string
  end
end
