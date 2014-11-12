#!/usr/bin/env ruby

# example: ./query_engine.rb -i input.txt -x >> output.csv

require_relative 'lib/configuration_provider'
require_relative 'lib/data_access/rally_work_item_detailer'
require_relative 'lib/formatters/work_item_formatter'
require_relative 'lib/rally_work_item_factory'

class QueryEngine
  include ConfigurationProvider
  include LoggingProvider

  def execute
    detailer = create_detailer configuration.system

    if configuration.options.feature?
      formatter = WorkItemFormatter.new configuration.stories
      formatter.dump
    else
      detailer = create_detailer configuration.system
      log.info "Processing #{configuration.stories.length} items"
      work_items = configuration.stories.map do |s|
        log.info "Build work item object for #{s}"
        begin
          data = detailer.get_data s
          work_item = RallyWorkItemFactory.create(data)
        rescue => e
          log.warn "#{e.message}, skipping item..."
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
