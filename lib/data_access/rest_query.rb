require_relative '../../lib/configuration_provider'

class RestQuery
  include ConfigurationProvider

  protected

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

      log.debug "POST Results: #{JSON.pretty_generate (JSON.load(results))}"
    rescue => e
      log.error e
      raise e
    end

    results
  end

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

      log.debug "GET Results: #{JSON.pretty_generate (JSON.load(results))}"
    rescue => e
      log.error e
      raise e
    end

    results
  end

  def credentials
    configuration.credentials
  end

  HTTP_OK = 200
  APP_JSON = 'application/json'
end
