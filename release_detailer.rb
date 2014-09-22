require 'logger'
require 'json'
require_relative 'rally_release_query'

class ReleaseDetailer
  def initialize(detail_query = RallyReleaseQuery.new)
    @detail_query = detail_query
  end

  def get_work_items(release_name)
    details = @detail_query.get_raw_story_list release_name
    results = JSON.parse(details)
    fail "No such release #{release_name}" if results['QueryResult']['TotalResultCount'] == 0
    stories = results['QueryResult']['Results'].map do |item|
      item['FormattedID']
    end
    stories
  end
end
