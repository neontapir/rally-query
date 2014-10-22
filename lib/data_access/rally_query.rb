require 'rest-client'
require 'open-uri'
require 'net/http'
require 'logger'
require 'json'
require 'base64'

require_relative '../configuration_provider'
require_relative '../logging_provider'

class RallyQuery
  include ConfigurationProvider
  include LoggingProvider

  def initialize
    if log.level == Logger::DEBUG
      RestClient.log = log
    end
  end

  def workspace_url
    raise "Missing webservice_root method in #{self.class}" unless respond_to? :webservice_root
    "#{webservice_root}/workspace/#{configuration.rally_workspace}"
  end

  def canonize(work_item_id)
    case work_item_id
      when /^(US|DE)\d+$/ then
        work_item_id
      when /^\d+$/ then
        "US#{work_item_id}"
      else
        nil
    end
  end

  def item_type_identifier(work_item_id)
    case work_item_id
      when /^US/ then
        'hierarchicalrequirement'
      when /^DE/ then
        'defect'
      else
        nil
    end
  end

  protected

  def credentials
    configuration.credentials
  end

  HTTP_OK = 200

  def make_get_rest_call(url)
    begin
      location = URI.encode url
      resource = RestClient::Resource.new(location,
                                          user: credentials[0],
                                          password: credentials[1],
                                          content_type: :json,
                                          accept: :json)
      results = resource.get
      raise "REST call failed, got #{results.code} status" unless results.code == HTTP_OK
    rescue => e
      log.error e
      raise e
    end
    results
  end

  APP_JSON = 'application/json'

  def make_post_rest_call(url, body)
    begin
      location = URI.encode url
      resource = RestClient::Resource.new(location,
                                          user: credentials[0],
                                          password: credentials[1])
      results = resource.post body,
                              content_type: APP_JSON,
                              accept: APP_JSON
      raise "REST call failed, got #{results.code} status" unless results.code == HTTP_OK
    rescue => e
      log.error e
      raise e
    end
    results
  end
end
