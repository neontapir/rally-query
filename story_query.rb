#!/usr/bin/env ruby

# example: ./story_query.rb -i input.txt -x >> output.csv

require_relative 'lib/configuration_provider'
require_relative 'lib/work_item_detailer'
require_relative 'lib/formatters/work_item_formatter'

class QueryEngine
  include ConfigurationProvider
  include LoggingProvider

  def execute
    if configuration.options.feature?
      formatter = WorkItemFormatter.new configuration.stories
      formatter.dump
    else
      detailer = WorkItemDetailer.new
      log.info "Processing #{configuration.stories.length} items"
      work_items = configuration.stories.map do |s|
        log.info "Build work item object for #{s}"
        begin
          work_item = WorkItem.new(detailer.get_data s)
        rescue => e
          log.warn "#{e.message}, skipping item..."
        end
        work_item # nil if not retrieved, filtered out later
      end
      formatter = WorkItemFormatter.new work_items
      formatter.dump
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  query_engine = QueryEngine.new
  query_engine.execute
end
