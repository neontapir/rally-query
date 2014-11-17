require 'logger'
require 'rest-client'
require_relative '../../lib/data_access/rest_query'

class JiraWorkItemLookup < RestQuery
  def initialize
    if configatron.log_level == Logger::DEBUG
      RestClient.log = log
    end
  end

  def get_data(work_item_id)
    url = "https://jira.exadel.com/rest/api/latest/issue/#{work_item_id}?-comments&expand=changelog"
    make_get_rest_call url
  end
end