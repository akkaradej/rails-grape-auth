class UserSerializer < BaseSerializer
  attributes(*(User.attribute_names).map(&:to_sym))

  def initialize(object, options={})
    super
    lazy_associate :has_many, :user_tokens
  end

  def short_keys
    [:id, :name, :email, :type]
  end

  def long_keys
    short_keys + [:banned, :created_at, :updated_at, :user_tokens]
  end
end