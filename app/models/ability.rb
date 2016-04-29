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

      can [:show, :edit, :update, :destroy, :recreate], Batch, user_id: user.id
      can [:index, :new, :create], Batch
      can [:index, :show, :new, :create], BatchItem
      can [:edit, :update, :destroy], BatchItem, { batch: { user_id: user.id }  }

    end

    if user.coordinator?

      # User with Coordinator Role can create new Users
      can [:new, :create], User

      # can also manage Users they created
      can [:index, :show, :edit, :update, :destroy], User, creator_id: user.id

    end

    if user.committer?

      # User with Committer Role can commit their own Batches
      can :commit, Batch, user_id: user.id

    end

  end

end

