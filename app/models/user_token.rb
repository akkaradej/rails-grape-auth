class UserToken < ActiveRecord::Base
  belongs_to :user

  before_create :generate_token
  # before_create :set_expiration

  # def expired?
  #   DateTime.now >= self.expires_at
  # end

  private

  def generate_token
    begin
      self.token = Devise.friendly_token
    end while UserToken.exists?(token: self.token)
  end

  # def set_expiration
  #   self.expires_at = DateTime.now+30
  # end

end