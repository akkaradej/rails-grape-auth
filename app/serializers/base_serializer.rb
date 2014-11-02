class BaseSerializer < ActiveModel::Serializer
  def initialize(object, options={})
    super
  end

  # super class make @only as array
  # @only = options[:only] ? Array(options[:only]) : nil

  # @only normally using for filter keys
  # So, we defined keys into 3 groups
  # [:short] => parent = short_keys / child = short_keys or no child
  # [:long]  => parent = long_keys  / child = short_keys
  # [:full]  => parent = long_keys  / child = long_keys

  def lazy_associate(assoc, resource)
    assoc_filter = @only == [:full] ? :long : :short
    self.class.send assoc, resource, only: assoc_filter
  end

  def filter(keys)
    if @only == [:short]
      short_keys
    elsif @only == [:long] or @only == [:full]
      long_keys
    else
      super
    end
  end

  def short_keys
    []
  end

  def long_keys
    short_keys
  end
end