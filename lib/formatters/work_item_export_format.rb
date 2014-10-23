require 'mustache'
require 'set'

require_relative '../configuration_provider'
require_relative '../work_item'
require_relative 'work_item_base_format'
require_relative '../work_item_export_extensions'

class WorkItemExportFormat < WorkItemBaseFormat
  include ConfigurationProvider
  include LoggingProvider

  attr_accessor :work_items, :show_header

  def initialize
    @show_header = configuration.options.header?
  end

  def stories
    # these field names need to match what's called in the Mustache template
    @work_items.compact.map do |w|
      {
          id: w.id,
          name: w.name,
          kanban_board: w.kanban_board,
          release: format_string(w.release),
          feature: w.feature,
          tags: w.tags,
          keywords: w.keywords,
          class_of_service: w.class_of_service,
          dev_lead: format_string(w.dev_lead),
          qa_lead: format_string(w.qa_lead),
          made_ready_in_validation: format_string(w.made_ready_in_validation),
          actual_story_points: w.actual_story_points,
          state: w.state,
          in_progress: w.in_progress,
          creation_date: format_date(w.creation_date),
          ready_date: format_date(w.ready_date),
          design_date: format_date(w.design_date),
          development_date: format_date(w.development_date),
          validation_date: format_date(w.validation_date),
          accepted_date: format_date(w.accepted_date),
          rejected_date: format_date(w.rejected_date),
          state_change_violations: w.state_change_violations,
          user_count: w.users,
          defect_count: w.defect_count,
          blocked_hours: format_number(w.blocked_hours),
          design_hours: format_number(w.design_hours),
          development_hours: format_number(w.development_hours),
          ready_hours: format_number(w.ready_hours),
          validation_hours: format_number(w.validation_hours),
          adjusted_design_hours: format_number(w.adjusted_design_hours),
          adjusted_development_hours: format_number(w.adjusted_development_hours),
          adjusted_ready_hours: format_number(w.adjusted_ready_hours),
          adjusted_validation_hours: format_number(w.adjusted_validation_hours),
          adjusted_cycle_time: format_number(w.adjusted_cycle_time),
      }
    end
  end

  def format_string(value)
    if value.to_s.empty? || value == 'N/A'
      '=NA()'
    else
      value
    end
  end

  def format_date(value)
    input = value.to_s
    if input.empty? || input == 'N/A'
      nil
    else
      Time.parse(input).localtime.strftime '%F'
    end
  end
end
