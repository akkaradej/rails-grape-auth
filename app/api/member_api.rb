class MemberApi < Grape::API
  resource :members do
    desc "member list"
    get '/', only: :short do
      members = Member.accessible_by(current_ability)
      paginate(members)
    end

    desc "create a member"
    params do
      requires :name,     type: String, desc: "Name"
      requires :email,    type: String, desc: "Email"
      requires :password, type: String, desc: "Password"
    end
    post '/' do
      authorize! :create, Member
      member = Member.create!(permitted_params)
      success(member)
    end

    desc "get a member"
    get ':id', only: :long do
      authorize! :read, Member
      Member.where(id: params[:id]).first || error404
    end

    desc "update a member"
    params do
      optional :name,     type: String, desc: "Name"
      optional :email,    type: String, desc: "Email"
      optional :password, type: String, desc: "Password"
    end
    put ':id' do
      member = Member.where(id: params[:id]).first || error404
      authorize! :update, member
      member.update!(permitted_params)
      success
    end

    desc "delete a capture box"
    delete ':id' do
      authorize! :destroy, Member
      member = Member.where(id: params[:id]).first || error404
      member.delete
      success
    end
  end
end