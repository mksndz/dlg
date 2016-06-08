module UserHelper
  def users_managed_by_and(coordinator_user)
    users_managed_by(coordinator_user) << coordinator_user
  end

  def users_managed_by(coordinator_user)
    coordinator_user.coordinator? ? User.where(creator_id: coordinator_user) : []
  end
end