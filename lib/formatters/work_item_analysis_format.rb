require 'mustache'
require_relative 'work_item_base_format'
require_relative 'work_item_export_format'
require_relative '../work_item'

class WorkItemAnalysisFormat < WorkItemExportFormat
  def format_date(value)
    input = value.to_s
    if input.empty? || input == 'N/A'
      nil
    else
      Time.parse(input).localtime.strftime '%Y%m%d'
    end
  end
end