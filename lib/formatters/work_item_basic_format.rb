require 'mustache'
require_relative 'work_item_base_format'
require_relative 'work_item_export_format'
require_relative '../work_item'

class WorkItemBasicFormat < WorkItemExportFormat
  def format_date(value)
    input = value.to_s
    if input.empty? || input == 'N/A'
      nil
    else
      Time.parse(input).localtime.strftime '%Y%m%d'
    end
  end

  def stories
    # these field names need to match what's called in the Mustache template
    @work_items.compact.map do |w|
      {
          id: w.id,
          name: w.name,
          release: format_string(w.release),
          feature: w.feature,
          tags: w.tags,
          dev_lead: format_string(w.dev_lead),
          qa_lead: format_string(w.qa_lead),
          actual_story_points: w.actual_story_points,
          creation_date: format_date(w.creation_date),
          requested_date: format_date(w.schedule_requested_date),
          defined_date: format_date(w.schedule_defined_date),
          in_progress_date: format_date(w.schedule_in_progress_date),
          completed_date: format_date(w.schedule_completed_date),
          accepted_date: format_date(w.schedule_accepted_date)
      }
    end
  end
end