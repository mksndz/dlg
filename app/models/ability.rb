class Ability
  include CanCan::Ability

  def initialize(user)

    can :manage, :catalog
    can :manage, :bookmarks

    if user.super?
      can :manage, :all
    end

    if user.basic?

      can [:index, :show, :new, :create, :edit, :update], Repository do |repository|
        user.repositories.include?(repository)
      end

      can [:index, :show, :new, :create, :edit, :update], Collection do |collection|
        user.repositories.include?(collection.repository) ||
            user.collections.include?(collection)
      end

      can [:index, :show, :new, :create, :edit, :update, :copy, :destroy, :search, :results], Item do |item|
        user.repositories.include?(item.repository) ||
            user.collections.include?(item.collection)
      end

      can [:show, :edit, :update, :destroy], Batch, user_id: user.id
      can [:index, :new, :create], Batch
      can [:index, :show, :new, :create], BatchItem
      can [:edit, :update, :destroy], BatchItem, { batch: { user_id: user.id }  }

    end

    if user.coordinator?

      can [:new, :create], User
      can [:index, :show, :edit, :update, :destroy], User, creator_id: user.id

    end

    if user.committer?

      can :commit, Batch, user_id: user.id

    end

  end

end

