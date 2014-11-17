require 'json'
require_relative '../lib/work_item'
require_relative '../lib/state_change'
require_relative '../lib/state_change_array'

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

    creator = (fields.fetch 'reporter').fetch 'displayName'
    result.state_changes = get_state_changes histories, creator, result.creation_date

    result
  end

  def get_state_changes(histories, issue_creator, create_date)
    histories_with_state_changes = histories.find_all do |x|
      x['items'].any? { |i| i['field'] == 'status' }
    end

    last_change_date = create_date
    current_status = nil
    changes = histories_with_state_changes.map do |change|
      sc = StateChange.new
      sc.object_id = change['key'].to_s
      sc.blocked_flag = false
      sc.ready_flag = false
      sc.valid_from = last_change_date.to_s
      sc.valid_to = change['created'].to_s
      last_change_date = sc.valid_to
      sc.user = change['author']['displayName'].to_s

      items = change['items']
      status_item = items.select { |i| i['field'] == 'status' }.first
      sc.state = canonize_state status_item['fromString']
      current_status = canonize_state status_item['toString']

      # sc.release = change['Release'].to_s
      # sc.blocked_flag = change['Blocked']
      # sc.ready_flag = change['Ready']

      # state = change['ScheduleState']
      # sc.schedule_state = SCHEDULE_STATE_STRING[state] || state.to_s

      sc #TODO: get rid of this temporary 'sc' object, maybe take a hash of options
    end

    current = StateChange.new
    current.object_id = nil
    current.blocked_flag = false
    current.ready_flag = false
    current.valid_from = last_change_date.to_s
    current.valid_to = Time.now.to_s
    current.user = changes.empty? ? issue_creator : changes.last.user
    current.state = current_status
    changes << current

    StateChangeArray.new(changes)
  end

  def canonize_state(state)
    # TODO: This is where Jira state will get canonized into a kanban state
    # TODO: Leverage WorkItemState here and in StateChangeArray
    # valid_states = %w(Ready Design Development Validation Accepted Rejected)
    state
  end

  def canonize_schedule_state(state)
    # TODO: This is where Jira state will get canonized into a schedule state
    # valid_states = ['Requested', 'Design', 'In Progress', 'Completed', 'Accepted']
    state
  end
end