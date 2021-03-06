require 'net/http'
require 'uri'
require 'json'
require 'rbconfig'
require_relative 'ConnectSDK/version'

class Connect_Api_Host
  API_HOST = "connect.gettyimages.com"
  API_BASE_URL = "https://#{API_HOST}"
end

class HttpHelper
  def initialize(api_key, access_token)
    @api_key      = api_key
    @access_token = access_token
  end

  def get_uri(path)
    URI.parse "#{Connect_Api_Host::API_BASE_URL}#{path}"
  end

  def get(endpoint_path, query_params)
    uri = get_uri(endpoint_path)
    if !query_params.nil?
      uri.query = URI.encode_www_form query_params
    end
    req = Net::HTTP::Get.new uri.request_uri
    send uri, req, @api_key, @access_token
  end

  def post(endpoint_path)
    uri = get_uri endpoint_path
    req = Net::HTTP::Post.new uri.request_uri
    send uri, req, @api_key, @access_token
  end

  private

  def os
    @os ||=
      begin
        host_os = RbConfig::CONFIG['host_os']
        case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        when /darwin|mac os/
          :macosx
        when /linux/
          :linux
        when /solaris|bsd/
          :unix
        else
          raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
        end
      end
  end

  def send(connect_uri, connect_request, api_key, bearer_token = "")
    https = Net::HTTP.new(connect_uri.host, connect_uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    connect_request["User-Agent"]      = "ConnectSDK/#{ConnectSDK::VERSION} (#{os} ; Ruby #{RUBY_VERSION})"
    connect_request["Api-Key"]         = api_key
    connect_request["Authorization"]   = "Bearer #{bearer_token}" unless bearer_token.empty?
    connect_request["Accept-Language"] = "ja"

    resp = https.request connect_request

    if !resp.is_a?(Net::HTTPSuccess)
      raise "HTTP RESPONSE: #{resp}"
    end

    JSON.parse(resp.body)
  end
end
