class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # is this needed since we use devise-guests?

    if user.admin?
      can :manage, :all
    end

    if user.basic?
      # can crud designated repo(+col) or col
      # can [:index, :new, :create, :edit, :update], [Repository, Collection, Item]
    end

    if user.coordinator?
      can [:new, :create], User
      can [:index, :edit, :update, :destroy], User, creator_id: user.id
    end

    if user.committer?
      # can commit their own Batches
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
