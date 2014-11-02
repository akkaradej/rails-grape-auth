class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.admin?
      admin(user)
    else
      member(user)
    end
  end

  # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  # can or cannot
  # class of resource or :all
  # :read, :create, :update, :destroy, :manage (for any), or custom

  def member(user)
    can :read, Member, banned: false
    can :update, Member, id: user.id
  end

  def admin(user)
    can :manage, :all
  end
end