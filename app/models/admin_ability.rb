class AdminAbility
  include CanCan::Ability

  def initialize(admin)

    admin ||= Admin.new # is this needed since we use devise-guests?

    if admin.super?
      can :manage, :all
    end

    if admin.basic?

      can [:index, :show, :new, :create, :edit, :update], Repository do |repository|
        admin.repositories.include?(repository)
      end

      can [:index, :show, :new, :create, :edit, :update], Collection do |collection|
        admin.repositories.include?(collection.repository) ||
            admin.collections.include?(collection)
      end

      can [:index, :show, :new, :create, :edit, :update, :copy, :destroy], Item do |item|
        admin.repositories.include?(item.repository) ||
            admin.collections.include?(item.collection)
      end

      can [:show, :edit, :update, :destroy], Meta::Batch, admin_id: admin.id
      can [:index, :new, :create], Meta::Batch
      can [:index, :show, :new, :create], Meta::BatchItem
      can [:edit, :update, :destroy], Meta::BatchItem, { batch: { admin_id: admin.id }  }

    end

    if admin.coordinator?

      can [:new, :create], Admin
      can [:index, :show, :edit, :update, :destroy], Admin, creator_id: admin.id

    end

    if admin.committer?

      can :commit, Meta::Batch, admin_id: admin.id

    end

  end

end

