#!/usr/bin/env ruby

# example: ./query_engine.rb -i input.txt -x >> output.csv

require 'configatron'
require_relative 'lib/configuration_factory'
require_relative 'lib/data_access/rally_work_item_detailer'
require_relative 'lib/formatters/work_item_formatter'
require_relative 'lib/rally_work_item_factory'

class QueryEngine


  def initialize
    ConfigurationFactory.ensure
  end

  def execute
    if configatron.options.feature?
      formatter = WorkItemFormatter.new configatron.stories
      formatter.dump
    else
      detailer = create_detailer configatron.system
      configatron.logger.info "Processing #{configatron.stories.length} items"
      work_items = configatron.stories.map do |s|
        configatron.logger.info "Build work item object for #{s}"
        begin
          data = detailer.get_data s
          work_item = RallyWorkItemFactory.create(data)
        rescue => e
          configatron.logger.warn "#{e.message}, skipping item..."
        end
        work_item # nil if not retrieved, filtered out later
      end
      formatter = WorkItemFormatter.new work_items
      formatter.dump
    end
  end

  def create_detailer(system)
    RallyWorkItemDetailer.new
  end

  def create_work_item(system, data)
    RallyWorkItemFactory.create(data)
  end
end

if __FILE__ == $PROGRAM_NAME
  query_engine = QueryEngine.new
  query_engine.execute
end
