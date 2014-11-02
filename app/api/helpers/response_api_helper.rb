module ResponseApiHelper
  def success(object=nil)
    # status 200 # uncomment to override, default of create is 201
    if object == nil
      { result: 'success' }
    else
      { id: object.id }
    end
  end

  def error400 # invalid param
    error!('400 Bad Request', 400)
  end

  def error401 # unauthorized
    error!('401 Unauthorized', 401)
  end

  def error404 # invalid route
    error!('404 Not Found', 404)
  end

  def error422 # before_* callback, or validation fail
    error!('422 Unprocessable Entity', 422)
  end

  def error500 # database error, server error
    error!('500 Internal Server Error', 500)
  end
end