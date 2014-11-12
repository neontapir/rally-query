require 'rest-client'
require 'open-uri'
require 'net/http'
require 'logger'
require 'json'
require 'base64'

require_relative '../configuration_provider'
require_relative '../logging_provider'
require_relative 'rest_query'

class RallyQuery < RestQuery
  include ConfigurationProvider
  include LoggingProvider

  def initialize
    if configuration.log_level == Logger::DEBUG
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
end
