class AdminApi < Grape::API
  resource :admins do
    desc "admin list"
    get '/', only: :short do
      authorize! :read, Admin
      paginate(Admin.all)
    end

    desc "create an admin"
    params do
      requires :name,     type: String, desc: "Name"
      requires :email,    type: String, desc: "Email"
      requires :password, type: String, desc: "Password"
    end
    post '/new' do
      authorize! :create, Admin
      admin = Admin.create(permitted_params)
      success(admin)
    end
  end
end