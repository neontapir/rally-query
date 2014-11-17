#!/usr/bin/env ruby

# example: ./query_engine.rb -i input.txt -x >> output.csv

require 'configatron'
require_relative 'lib/configuration_factory'
require_relative 'lib/data_access/jira_work_item_lookup'
require_relative 'lib/data_access/rally_work_item_lookup'
require_relative 'lib/formatters/work_item_formatter'
require_relative 'lib/jira_work_item_factory'
require_relative 'lib/rally_work_item_factory'

class QueryEngine
  def initialize
    ConfigurationFactory.ensure
  end

  def execute
    if configatron.options.feature?
      # TODO: fix name of 'stories' to be inclusive
      formatter = WorkItemFormatter.new configatron.stories
    else
      formatter = WorkItemFormatter.new get_work_items
    end
    formatter.dump
  end

  private

  def get_work_items
    system = configatron.system
    lookup = get_detailer system
    raise "Cannot use #{lookup.class} to lookup work item data" unless lookup.respond_to? :get_data
    work_item_factory = get_work_item_factory system
    raise "Cannot use #{work_item_factory.class} to create a work item object" unless work_item_factory.respond_to? :create

    configatron.logger.info "Processing #{configatron.stories.length} items"
    configatron.stories.map do |s|
      configatron.logger.info "Build work item object for #{s}"
      begin
        detail_data = lookup.get_data s
        work_item = work_item_factory.create(detail_data)
      rescue => e
        configatron.logger.warn "#{e.message}, skipping item..."
      end
      work_item # nil if not retrieved, filtered out later
    end
  end

  def get_detailer(system)
    case system
      when 'Rally'
        RallyWorkItemLookup.new
      when 'Jira'
        JiraWorkItemLookup.new
      else
        nil
    end
  end

  def get_work_item_factory(system)
    case system
      when 'Rally'
        RallyWorkItemFactory
      when 'Jira'
        JiraWorkItemFactory
      else
        nil
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  query_engine = QueryEngine.new
  query_engine.execute
end
