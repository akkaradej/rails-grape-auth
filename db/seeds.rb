# Create dummy users and their token in each role
if Rails.env.development? or Rails.env.staging?
  unless UserToken.exists?(token: "admin_token")
    UserToken.skip_callback(:create, :before, :generate_token)
    
    admin = Admin.create(name: 'admin', email: 'admin@example.com', password: 'admin')
    admin.user_tokens.create(token: "admin_token")

    member = Member.create(name: 'member', email: 'member@example.com', password: 'member')
    member.user_tokens.create(token: "member_token")

    UserToken.set_callback(:create, :before, :generate_token)
  end
end