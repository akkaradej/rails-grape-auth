class AuthApi < Grape::API
  resource :auth do
    before_validation { @skip_authen = true }

    desc "Member register"
    params do
      requires :name,     type: String, desc: "Name"
      requires :email,    type: String, desc: "Email"
      requires :password, type: String, desc: "Password"
    end
    post '/register' do
      member = Member.create!(permitted_params)
      success(member)
    end
    
    desc "Login and generate token"
    params do
      requires :email,    type: String, desc: "Email"
      requires :password, type: String, desc: "Password"
    end
    post '/' do
      user = User.where(email: params[:email].downcase).first
      if user and user.valid_password?(params[:password])
        user_token = UserToken.create!(user_id: user.id)
        { 
          token: user_token.token, 
          type: user.type
        }
      else
        error401
      end
    end

    desc "Logout and remove token"
    delete '/' do
      if headers['Authorization'] && token = UserToken.where(token: headers['Authorization']).first
        token.destroy
        { result: 'success' }
      else
        error401
      end
    end
  end
end