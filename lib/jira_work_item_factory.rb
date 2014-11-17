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
    valid_from = result.creation_date
    histories.each do |change|
      get_state_changes
    end

    result
  end
end