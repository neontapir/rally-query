require 'configatron'

require_relative '../configuration_factory'
require_relative 'rest_query'

class RallyQuery < RestQuery
  def initialize
    ConfigurationFactory.ensure
    if configatron.log_level == Logger::DEBUG
      RestClient.log = configatron.log
    end
  end

  def workspace_url
    raise "Missing webservice_root method in #{self.class}" unless respond_to? :webservice_root
    "#{webservice_root}/workspace/#{configatron.rally_workspace}"
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
