module AuthApiHelper
  def authenticate!
    if headers['Authorization'] and user_token = UserToken.where(token: headers['Authorization']).first
      @current_user = User.where(id: user_token.user_id).first
    else
      error!("401 Unauthorized", 401)
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def authorize!(*args)
    current_ability.authorize!(*args)
  end

  def current_user
    @current_user
  end
end