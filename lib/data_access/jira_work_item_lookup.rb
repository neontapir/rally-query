require 'logger'
require 'rest-client'

require_relative 'jira_query'

class JiraWorkItemLookup < JiraQuery
  def get_data(work_item_id)
    url = "https://jira.hybris.com/rest/api/latest/issue/#{work_item_id}?-comments&expand=changelog"
    make_get_rest_call url
  end
end
