require 'json'

require_relative 'configuration_provider'
require_relative 'logging_provider'
require_relative 'state_changes_array'

class WorkItem
  include ConfigurationProvider
  include LoggingProvider

  attr_accessor :id, :name, :title, :project, :feature, :release, :tags, :state_changes,
                :defect_count, :defects_status, :story_points, :current_state, :kanban_field,
                :creation_date, :schedule_dates

  def initialize(raw_data)
    create_item raw_data
  end

  def create_item(raw_data)
    raise "raw_data is not a Hash, it's a #{raw_data.class}" unless raw_data.is_a? Hash

    log.debug "Raw data: #{JSON.pretty_generate(raw_data)}"

    parsed_data = JSON.dump(raw_data.fetch(:detail))
    data = JSON.parse(parsed_data).first

    @id = data.fetch 'FormattedID'
    @name = data.fetch '_refObjectName'
    @story_points = data.fetch 'PlanEstimate'
    @kanban_field = raw_data.fetch(:kanban_field_name) || 'ScheduleState'
    @creation_date = data.fetch 'CreationDate'
    @current_state = data.fetch @kanban_field

    @project = get_item_name_or_nil data, 'Project'
    @release = get_item_name_or_nil data, 'Release'
    @feature = get_item_name_or_nil data, 'PortfolioItem'

    defects = data.fetch('Defects', nil)
    @defect_count = defects ? defects.fetch('Count') : 0

    @defects_status = defects ? data.fetch('DefectStatus') : nil

    create_tags data
    @state_changes = StateChangeArray.new raw_data, @kanban_field
  end

  def get_item_name_or_nil(data, item_name)
    item = data.fetch(item_name, nil)
    log.debug "Found no #{item_name} for #{@id}" if item.nil?
    item ? item.fetch('_refObjectName') : nil
  end

  def create_tags(data)
    the_tags = data.fetch('Tags').fetch('_tagsNameArray')
    tags = the_tags.map { |x| x['Name'] }
    @tags = tags.join(',')
  end

  def keywords
    # note: spaces are escaped in a %w string
    @keyword_items ||= Set.new %w(User Security Party Flows Rules Contactinfo Info IDs Adapters \
       Organization Activity Audit Adapter\ Types Context Compatibility Testing Navigation \
       Relationships IE Errors Certificates SMS S3 Database Infrastructure AWS Prototyping API \
       Broker DREV TPM Jmeter Performance IAM AMI Test Build Smooks Deploy UE Implementation QoS \
       eInvoicing LDAP EB Alerts ETL Activity Framework DocSim Tika Environment Data-Commons \
       Rule\ Type Metrics Data\ Poller)
    keys = @keyword_items.select do |w|
      /#{w}/i =~ @name
    end
    keys.join(',')
  end

  def class_of_service
    @class_of_service ||= ClassOfService.new @id, @name
  end

  def kanban_board
    @kanban_board ||= KanbanBoard.new @project
  end

  def users
    @state_changes.map(&:user).uniq.length
  end

  def blocked_hours
    @state_changes.blocked_hours
  end

  def state_change_violations
    @state_changes.state_change_violations
  end

  def status_counts
    @state_changes.status_counts
  end

  def dev_lead
    @state_changes.dev_lead
  end

  def qa_lead
    @state_changes.qa_lead
  end

  def made_ready_in_validation
    @state_changes.made_ready_in_validation
  end

  def ready_date
    @state_changes.story_dates['Ready']
  end

  def design_date
    @state_changes.story_dates['Design']
  end

  def development_date
    @state_changes.story_dates['Development']
  end

  def validation_date
    @state_changes.story_dates['Validation']
  end

  def accepted_date
    @state_changes.story_dates['Accepted']
  end

  def rejected_date
    @state_changes.story_dates['Rejected']
  end

  def schedule_requested_date
    @state_changes.schedule_state_dates['Requested']
  end

  def schedule_defined_date
    @state_changes.schedule_state_dates['Defined']
  end

  def schedule_in_progress_date
    @state_changes.schedule_state_dates['In Progress']
  end

  def schedule_completed_date
    @state_changes.schedule_state_dates['Completed']
  end

  def schedule_accepted_date
    @state_changes.schedule_state_dates['Accepted']
  end
end