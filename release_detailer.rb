require 'logger'
require 'json'
require_relative 'rally_release_query'

class ReleaseDetailer
  def initialize(detail_query = RallyReleaseQuery.new)
    @detail_query = detail_query
  end

  def get_work_items(release_name)
    # details = @detail_query.get_raw_story_list release_name
    # results = JSON.parse(details)
    # fail "No such release #{release_name}" if results['QueryResult']['TotalResultCount'] == 0
    # stories = results['QueryResult']['Results'].map do |item|
    #   item['FormattedID']
    # end
    # stories
    stories = get_stories release_name
    stories += get_defects release_name
  end

  private

  def get_stories(release_name)
    get_items(release_name) { |r| @detail_query.get_raw_story_list r }
  end

  def get_defects(release_name)
    get_items(release_name) { |r| @detail_query.get_raw_defect_list r }
  end

  def get_items(release_name, &lookup_method)
    details = lookup_method.call release_name
    results = JSON.parse(details)
    fail "No such release #{release_name}" if results['QueryResult']['TotalResultCount'] == 0
    stories = results['QueryResult']['Results'].map do |item|
      item['FormattedID']
    end
    stories
  end
end
