require 'logger'
require 'json'
require_relative 'rally_project_query'

class ProjectDetailer
  def initialize(detail_query = RallyProjectQuery.new)
    @detail_query = detail_query
  end

  def get_work_items(release_name)
    work_items = get_stories release_name
    work_items += get_defects release_name
  end

  def get_portfolio_items(release_name)
    details = @detail_query.get_raw_story_list_with_portfolio_items release_name
    results = JSON.parse(details)
    fail "No such release #{release_name}" if results['QueryResult']['TotalResultCount'] == 0
    work_items = results['QueryResult']['Results'].map do |item|
      item['PortfolioItem']
    end
    work_items = work_items.compact.map { |i| i['FormattedID'] }
    work_items.uniq
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
    work_items = results['QueryResult']['Results'].map do |item|
      item['FormattedID']
    end
    work_items
  end
end
