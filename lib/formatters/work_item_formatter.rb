require 'configatron'

require_relative 'work_item_analysis_format'
require_relative 'work_item_base_format'
require_relative 'work_item_basic_format'
require_relative 'work_item_export_format'
require_relative 'work_item_feature_format'
require_relative 'work_item_screen_format'

class WorkItemFormatter
  attr_reader :format

  def initialize(work_items, formatter = nil)
    if formatter.nil?
      configatron.logger.debug "Format using #{formatter_class}"
      @format = formatter_class.new
    else
      @format = formatter
    end

    @format.work_items = Array(work_items)
  end

  def formatter_class
    Object.const_get(configatron.formatter)
  end

  def dump
    puts @format.render
  end
end
