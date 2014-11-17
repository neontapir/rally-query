require 'json'

require_relative 'configuration_factory'
require_relative 'rally_state_change'
require_relative 'state_change_array'
require_relative 'kanban_board'
require_relative 'class_of_service'
require_relative 'work_item'

class RallyWorkItemFactory
  def create(raw_data)
    create_item raw_data
  end

  private

  def create_item(raw_data)
    result = WorkItem.new

    raise "raw_data is not a Hash, it's a #{raw_data.class}" unless raw_data.is_a? Hash

    ConfigurationFactory.ensure
    configatron.logger.debug "Raw data: #{JSON.pretty_generate(raw_data)}"

    parsed_data = JSON.dump(raw_data.fetch(:detail))
    data = JSON.parse(parsed_data).first

    result.id = data.fetch 'FormattedID'
    result.name = data.fetch '_refObjectName'
    result.story_points = data.fetch 'PlanEstimate'
    result.kanban_field = raw_data.fetch(:kanban_field_name) || 'ScheduleState'
    result.creation_date = data.fetch 'CreationDate'
    result.current_state = data.fetch result.kanban_field

    result.project = get_item_name_or_nil result.id, data, 'Project'
    result.release = get_item_name_or_nil result.id, data, 'Release'
    result.feature = get_item_name_or_nil result.id, data, 'PortfolioItem'

    defects = data.fetch('Defects', nil)
    result.defect_count = defects ? defects.fetch('Count') : 0
    result.defects_status = defects ? data.fetch('DefectStatus') : nil

    result.tags = create_tags data
    result.state_changes = create_changes_array raw_data, result.kanban_field

    result
  end

  SCHEDULE_STATE_STRING = { 208717799 => 'Requested', 208717800 => 'Defined', 208717801 => 'In Progress',
                            208717802 => 'Completed', 208717803 => 'Accepted' }.freeze

  def create_changes_array(raw_data, kanban_field)
    lookback_data = raw_data[:lookback]

    parsed_data = JSON.dump(lookback_data)
    data = JSON.parse(parsed_data)

    changes = data.map do |change|
      sc = RallyStateChange.new
      sc.object_id = change['ObjectId'].to_s
      sc.release = change['Release'].to_s
      sc.valid_from = change['_ValidFrom'].to_s
      sc.valid_to = change['_ValidTo'].to_s
      sc.blocked_flag = change['Blocked']
      sc.ready_flag = change['Ready']
      sc.user = change['_User'].to_s
      state = change['ScheduleState']
      sc.schedule_state = SCHEDULE_STATE_STRING[state] || state.to_s
      sc.state = change[kanban_field].to_s

      sc #TODO: get rid of this temporary 'sc' object, maybe take a hash of options
    end

    StateChangeArray.new(changes)
  end

  def get_item_name_or_nil(id, data, item_name)
    item = data.fetch(item_name, nil)
    configatron.logger.debug "Found no #{item_name} for #{id}" if item.nil?
    item ? item.fetch('_refObjectName') : nil
  end

  def create_tags(data)
    the_tags = data.fetch('Tags').fetch('_tagsNameArray')
    tags = the_tags.map { |x| x['Name'] }
    tags.join(',')
  end
end