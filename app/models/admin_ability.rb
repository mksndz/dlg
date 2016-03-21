class AdminAbility
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # is this needed since we use devise-guests?

    if user.admin?
      can :manage, :all
    end

    if user.basic?

      can [:index, :show, :new, :create, :edit, :update], Admin::Repository do |repository|
        user.repositories.include?(repository)
      end

      can [:index, :show, :new, :create, :edit, :update], Admin::Collection do |collection|
        user.repositories.include?(collection.repository) ||
            user.collections.include?(collection)
      end

      can [:index, :show, :new, :create, :edit, :update, :copy, :destroy], Admin::Item do |item|
        user.repositories.include?(item.repository) ||
            user.collections.include?(item.collection)
      end

      can [:show, :edit, :update, :destroy], Admin::Batch, user_id: user.id
      can [:index, :new, :create], Admin::Batch
      can [:index, :show, :new, :create], Admin::BatchItem
      can [:edit, :update, :destroy], Admin::BatchItem, { batch: { user_id: user.id }  }

    end

    if user.coordinator?

      can [:new, :create], User
      can [:index, :show, :edit, :update, :destroy], User, creator_id: user.id

    end

    if user.committer?

      can :commit, Admin::Batch, user_id: user.id

    end

  end

end

