require 'json'

require_relative 'configuration_factory'
require_relative 'state_change_array'
require_relative 'kanban_board'
require_relative 'class_of_service'
require_relative 'work_item'

class RallyWorkItemFactory
  def self.create(raw_data)
    create_item raw_data
  end

  private

  def self.create_item(raw_data)
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
    result.state_changes = StateChangeArray.new raw_data, result.kanban_field

    result
  end

  def self.get_item_name_or_nil(id, data, item_name)
    item = data.fetch(item_name, nil)
    configatron.logger.debug "Found no #{item_name} for #{id}" if item.nil?
    item ? item.fetch('_refObjectName') : nil
  end

  def self.create_tags(data)
    the_tags = data.fetch('Tags').fetch('_tagsNameArray')
    tags = the_tags.map { |x| x['Name'] }
    tags.join(',')
  end
end