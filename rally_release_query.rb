require 'rest-client'
require 'open-uri'
require 'logger'

require_relative 'query'

class RallyReleaseQuery < Query
  WEBSERVICE_ROOT = 'https://rally1.rallydev.com/slm/webservice/v2.0'

  def webservice_root
    WEBSERVICE_ROOT
  end

  def get_raw_story_list(release_name)
    item_type = item_type_identifier 'US'
    query = "#{WEBSERVICE_ROOT}/#{item_type}?workspace=#{workspace_url}&query=(Release.Name = \"#{release_name}\")&fetch=FormattedID"
    make_get_rest_call query
  end
end
