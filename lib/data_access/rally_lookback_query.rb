require 'rest-client'
require 'open-uri'
require 'logger'
require_relative 'rally_query'

class RallyLookbackQuery < RallyQuery
  WEBSERVICE_ROOT = 'https://rally1.rallydev.com/analytics/v2.0/service/rally'

  def webservice_root
    WEBSERVICE_ROOT
  end

  def get_raw_lookback(work_item_id, project)
    story = canonize work_item_id
    url = "#{workspace_url}/artifact/snapshot/query.json"

    kanban_field_spec = ''
    kanban_field = get_kanban_field_name project
    unless kanban_field.nil?
      kanban_field_spec = ",\"#{kanban_field}\""
    end

    raise 'Bad story ID' if story.empty?
    #raise 'Bad kanban field ID' if kanban_field.empty?

    filter = %({ "find" : { "FormattedID": "#{story}" }, \
                 "fields" : ["ObjectID", "_ValidFrom", "_ValidTo", "Release", "Blocked", "Ready", "_User", "ScheduleState" #{kanban_field_spec}], \
                 "compress" : true,
                 "start": 0,
                 "pagesize": 1000 })

    make_post_rest_call url, filter
  end

  def get_kanban_field_name(project)
    case project
      when /Backend|R&D|Teams|TPM/
        'c_EGXKanbanState'
      when /GUI/
        'c_EGXGUIKanbanState'
      else
        nil # raise "Unknown project '#{project}'"
    end
  end
end
