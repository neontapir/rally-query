require 'json'
require_relative '../lib/work_item'

class JiraWorkItemFactory
  def create(raw_data)
    create_item raw_data
  end

  private

  def create_item(raw_data)
    data = JSON.parse(raw_data)

    result = WorkItem.new
    result.id = data.fetch 'key'

    fields = data.fetch 'fields'
    result.name = fields.fetch 'summary'
    result.title = result.name
    result.project = (fields.fetch 'project').fetch 'key'

    # TODO: Use GreenHopper API to look up Epic Link -> feature
    # TODO: See how kanban_field is used to decide how to map it

    status = fields.fetch 'status'
    result.current_state = (status.fetch 'statusCategory').fetch 'name'
    result.creation_date = fields.fetch 'created'

    histories = (data.fetch 'changelog').fetch 'histories'

    result.state_changes = get_state_changes histories

    result
  end

  def get_state_changes(data)
    changes = data.map do |change|
      sc = StateChange.new
      sc.object_id = change['key'].to_s
      # sc.release = change['Release'].to_s
      # sc.valid_from = change['_ValidFrom'].to_s
      # sc.valid_to = change['_ValidTo'].to_s
      # sc.blocked_flag = change['Blocked']
      # sc.ready_flag = change['Ready']
      # sc.user = change['_User'].to_s
      # state = change['ScheduleState']
      # sc.schedule_state = SCHEDULE_STATE_STRING[state] || state.to_s
      # sc.state = change[kanban_field].to_s

      sc #TODO: get rid of this temporary 'sc' object, maybe take a hash of options
    end

    StateChangeArray.new(changes)
  end
end