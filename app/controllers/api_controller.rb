class ApiController < ApplicationController
  before_action :cors_preflight_check
  before_action :check_content_type #will uncomment this when going live. else we always need to set add content_type headder as application/json
  before_action :authenticate_api
  before_action :get_filter,
                if: lambda { |allow|
                  request.method == 'GET' and params[:filters].present?
                }
  around_action :catch_errors
  after_action :add_header

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] =
        'POST, GET, PUT, DELETE, OPTIONS, PATCH'
      headers['Access-Control-Allow-Headers'] =
        'X-Requested-With, X-Prototype-Version, Token, X-Request-Origin'
      headers['Access-Control-Max-Age'] = '1728000'

      render text: '', content_type: 'text/plain'
    end
  end

  def get_filter
    filters =
      begin
        JSON.parse(params[:filters]).nested_under_indifferent_access
      rescue StandardError
        {}
      end
    self.params = params.except(:filters).merge(filters)
  end

  def add_header
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] =
      'POST, PUT, DELETE, GET, OPTIONS, PATCH'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] =
      'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    response_type =
      (params['format'] == 'html') ? 'text/html' : 'application/json'
    headers['Content-Type'] = @content_type || response_type
    #headers["if_modified_since off"] = "off"
    headers['Token'] = token
  end

  def authenticate_api
    if request.headers['HTTP_API_TOKEN'].present?
      app_key, app_secret =
        Base64.decode64(request.headers['HTTP_API_TOKEN']).split(/:/, 2)
    end
    if params['token'].present?
      app_key, app_secret = Base64.decode64(params['token']).split(/:/, 2)
    end
    unless app_key and app_secret and
             APP_CONFIG['api_client'][app_key].present? and
             APP_CONFIG['api_client'][app_key]['app_secret'] == app_secret
      render_api_error(13, 401)
    else
      @device = APP_CONFIG['api_client'][app_key]['device']
      @version = version
    end
  end

  def authenticate_user
    render_api_error(10, 401) unless get_user
  end

  def token
    @token = request.headers['HTTP_TOKEN'] || User.generate_access_token
  end

  def current_user
    @user = @user || get_user
  end

  def get_user
    if request.headers['HTTP_ACCESS_TOKEN'].present?
      @token, email =
        Base64.decode64(request.headers['HTTP_ACCESS_TOKEN']).split(/:/, 2)
    end
    if params['t'].present?
      @token, email = Base64.decode64(params['t']).split(/:/, 2)
    end
    @user if @user = User.check_redis_token(email, @token, @device)
  end

  def check_content_type
    if request.method == 'POST' || request.method == 'PATCH' ||
         request.method == 'PUT'
      unless request.content_type.in?(%w[application/json multipart/form-data])
        render_api_error(
          12,
          400,
          'request',
          "Only content type application/json is accepted.  Your content type: #{
            request.content_type
          }"
        )
      end
    end
  end

  def render_api_error(
    code, status_code, type = 'error', message = nil, extra_params = {}
  )
    error = {}
    error['code'] = code
    error['type'] = type
    error['message'] = message || APP_CONFIG['error'][code]
    response = { 'error' => error }.merge (extra_params || {})
    render json: response, status: status_code
  end

  def device
    @device || (params[:device] || 'default') #need to decide how to find out device
  end

  def version
    @version || (request.headers['HTTP_APP_VERSION'].to_i || 0)
  end

  def limit
    params[:limit] || 100
  end

  def offset
    params[:offset] || 0
  end

  def page
    params[:page] || 0
  end

  def per_page
    limit = 1000
    if params[:page].present?
      if device == 'desktop'
        limit = APP_CONFIG['per_page']['desktop']
      elsif device != 'android'
        limit = APP_CONFIG['per_page']['mobile_site']
      end
    end
    return limit
  end

  def filter_data
    final_data = []
    if params[:filter].present?
      filter_type = []
      params[:filter].each do |value|
        final_data.push(
          value.last.map do |result|
            "#{value.first.downcase}|#{result.downcase}"
          end
        )
      end
    end
    return final_data
  end

  def order_by
    table = params[:controller].split('/').last
    if params[:order_by].present?
      "#{table}.#{params[:order_by]}"
    else
      "#{table}.id desc"
    end
  end

  def page_not_found
    render_api_error(0o1, 404, 'request')
  end

  def catch_errors
    yield
  rescue Exception => e
    Rails.logger.error(
      "Unhandled API Error: #{e.to_s}.\n Params:\n #{
        params.to_s
      } \n Backtrace:\n#{e.backtrace.join("\n")}"
    )
    # NewRelic::Agent.notice_error(
    #   e,
    #   { custom_params: set_custom_params_to_track }
    # )
    render_api_error(0o2, 500, 'server', "API internal error: #{e.to_s}")
  end

  def x_request_origin
    @x_request_origin = request.headers['HTTP_X_REQUEST_ORIGIN']
  end

  def currency
    APP_CONFIG['rupee_symbol']
  end
end
