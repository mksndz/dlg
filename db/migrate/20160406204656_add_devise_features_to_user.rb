class AddDeviseFeaturesToUser < ActiveRecord::Migration
    def up
      change_table :users do |t|

        # Invitable
        t.string     :invitation_token
        t.datetime   :invitation_created_at
        t.datetime   :invitation_sent_at
        t.datetime   :invitation_accepted_at
        t.integer    :invitation_limit
        t.references :invited_by, polymorphic: true
        t.integer    :invitations_count, default: 0
        t.index      :invitations_count
        t.index      :invitation_token, unique: true # for invitable
        t.index      :invited_by_id

        # Lockable
        t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
        t.string   :unlock_token # Only if unlock strategy is :email or :both
        t.datetime :locked_at

      end
    end

    def down
      change_table :users do |t|
        t.remove_references :invited_by, polymorphic: true
        t.remove :invitations_count, :invitation_limit, :invitation_sent_at, :invitation_accepted_at, :invitation_token, :invitation_created_at
        t.remove :failed_attempts, :unlock_token, :locked_at
      end
    end
end
