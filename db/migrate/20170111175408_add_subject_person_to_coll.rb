class AddSubjectPersonToColl < ActiveRecord::Migration
  def change

    change_table :collections do |t|

      t.text    :dlg_subject_personal, array: true, null: false, default: []

    end

  end
end
