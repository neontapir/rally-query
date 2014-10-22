require_relative 'configuration_provider'
require_relative 'work_item'
require_relative 'work_item_analysis_format'
require_relative 'work_item_base_format'
require_relative 'work_item_export_format'
require_relative 'work_item_feature_format'
require_relative 'work_item_screen_format'

class WorkItemFormatter
  include ConfigurationProvider
  include LoggingProvider

  attr_reader :format

  def initialize(work_items, formatter = nil)
    if formatter.nil?
      formatter_class = Object.const_get(configuration.formatter)
      log.debug "Format using #{formatter_class}"
      @format = formatter_class.new
    else
      @format = formatter
    end

    @format.work_items = Array(work_items)
  end

  def dump
    puts @format.render
  end
end
