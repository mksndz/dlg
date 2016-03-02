class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # is this needed since we use devise-guests?

    if user.admin?
      can :manage, :all
    elsif user.coordinator?
      can :manage, [Repository, Collection, Item]
      can :manage, [Batch, BatchItem]
      can [:index, :new, :create], User
    elsif user.basic?
      can [:index, :new, :create, :edit, :update], [Repository, Collection, Item]
    else
      cannot :manage, :all
    end

  end
end
