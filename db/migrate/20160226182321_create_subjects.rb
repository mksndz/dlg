class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :subjects_collections do |t|
      t.integer :subject_id, index: true
      t.integer :collection_id, index: true
    end
  end
end
