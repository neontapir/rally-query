require 'logger'
require 'json'
require_relative 'data_access/rally_project_query'
require_relative 'data_access/rally_release_query'

class GroupDetailerBase
  attr_accessor :detail_query
  attr_accessor :group_identifier

  def initialize(detail_query = RallyReleaseQuery.new, group_identifier = 'unknown')
    @detail_query = detail_query
    @group_identifier = group_identifier
  end

  def get_work_items(group_name)
    work_items = get_stories group_name
    work_items += get_defects group_name
  end

  def get_portfolio_items(group_name)
    details = @detail_query.get_raw_story_list_with_portfolio_items group_name
    results = JSON.parse(details)
    warn "No such #{@group_identifier} #{group_name}" if results['QueryResult']['TotalResultCount'] == 0
    work_items = results['QueryResult']['Results'].map do |item|
      item['PortfolioItem']
    end
    work_items = work_items.compact.map { |i| i['FormattedID'] }
    work_items.uniq
  end

  private

  def get_stories(group_name)
    get_items(group_name) { |r| @detail_query.get_raw_story_list r }
  end

  def get_defects(group_name)
    get_items(group_name) { |r| @detail_query.get_raw_defect_list r }
  end

  def get_items(group_name, &lookup_method)
    details = lookup_method.call group_name
    results = JSON.parse(details)
    warn "No such #{@group_identifier} #{group_name}" if results['QueryResult']['TotalResultCount'] == 0
    work_items = results['QueryResult']['Results'].map do |item|
      item['FormattedID']
    end
    work_items
  end
end
