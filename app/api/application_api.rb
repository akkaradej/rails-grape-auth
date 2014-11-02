class ApplicationApi < Grape::API
  include Grape::Kaminari
  format :json
  formatter :json, Grape::Formatter::ActiveModelSerializers

  require_relative 'helpers/param_api_helper'
  require_relative 'helpers/response_api_helper'
  helpers ParamApiHelper
  helpers ResponseApiHelper
  helpers AuthApiHelper

  rescue_from CanCan::AccessDenied do |e|
    Rack::Response.new({
      error: "401 Unauthorized"
    }.to_json, 401)
  end

  # comment this if you want to make public api
  after_validation do
    authenticate! unless @skip_authen || !!(request.env['PATH_INFO'] =~ /\A\/doc(|\/.*)(.json)?\z/) # doc
  end

  mount AuthApi
  mount MemberApi
  mount AdminApi

  add_swagger_documentation base_path: 'api', api_version: '1.0', 
    mount_path: '/doc.json', hide_format: true, hide_documentation_path: true,
    markdown: GrapeSwagger::Markdown::RedcarpetAdapter.new(render_options: { highlighter: :rouge })

  route :any, '*path' do
    error404
  end
end