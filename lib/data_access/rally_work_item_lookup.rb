require 'logger'
require 'json'
require_relative 'rally_detail_query'
require_relative 'rally_lookback_query'

class RallyWorkItemLookup
  def initialize(detail_query = RallyDetailQuery.new, lookback_query = RallyLookbackQuery.new)
    @detail_query = detail_query
    @lookback_query = lookback_query
  end

  def get_data(work_item_id)
    detail = get_detail work_item_id
    raise "Data is a #{detail.class} for #{work_item_id}" unless detail.is_a? Array
    raise "Data is empty for #{work_item_id}" if detail == []

    the_project = detail.first['Project']
    project = the_project.nil? ? nil : the_project['_refObjectName']
    raise 'Project is empty' if project.empty?

    lookback = get_lookback work_item_id, project

    # TODO: Promote to object
    kanban_field_name = @lookback_query.get_kanban_field_name project
    {kanban_field_name: kanban_field_name, detail: detail, lookback: lookback}
  end

  def get_detail(work_item_id)
    details = @detail_query.get_raw_details work_item_id
    results = JSON.parse(details)
    raise "No such work item #{work_item_id}" if details['TotalResultCount'] == 0
    configatron.logger.debug "Detail #{work_item_id}: #{JSON.pretty_generate results}"
    results['QueryResult']['Results']
  end

  def get_lookback(work_item_id, project)
    details = @lookback_query.get_raw_lookback work_item_id, project
    results = JSON.parse(details)
    configatron.logger.debug "Lookback #{work_item_id}, #{project}: #{JSON.pretty_generate results}"
    results['Results']
  end

  def get_release(release_id)
    details = @detail_query.get_raw_release release_id
    results = JSON.parse(details)
    configatron.logger.debug "Release #{release_id}: #{JSON.pretty_generate results}"
    results['Release']
  end

  def get_user(user_id)
    details = @detail_query.get_raw_user user_id
    results = JSON.parse(details)
    configatron.logger.debug "User #{user_id}: #{JSON.pretty_generate results}"
    results['User']
  end
end
