class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # is this needed since we use devise-guests?

    if user.admin?
      can :manage, :all
    end

    if user.basic?

      can [:index, :new, :create, :edit, :update, :copy], Repository do |repository|
        user.repositories.include?(repository)
      end

      can [:index, :new, :create, :edit, :update, :copy], Collection do |collection|
        user.repositories.include?(collection.repository) ||
            user.collections.include?(collection)
      end

      can [:index, :new, :create, :edit, :update, :copy], Item do |item|
        user.repositories.include?(item.repository) ||
            user.collections.include?(item.collection)
      end

      can [:index, :edit, :update, :destroy], Batch, user_id: user.id
      can [:new, :create], Batch
      can [:index, :new, :create], BatchItem
      can [:edit, :update, :destroy], BatchItem, { batch: { user_id: user.id }  }

    end

    if user.coordinator?

      can [:new, :create], User
      can [:index, :edit, :update, :destroy], User, creator_id: user.id

    end

    if user.committer?

      can :commit, Batch, user_id: user.id

    end


  end

  private

  # def check_permissions
  #   can do |action, subject_class, subject|
  #     user.permissions.where(action: action).any? do |permission|
  #       permission.class_name == subject_class.to_s && (subject.nil? || permission.entity_id.nil? || permission.entity_id == subject.id)
  #     end
  #   end
  # end
end
