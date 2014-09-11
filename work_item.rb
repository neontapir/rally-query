require 'json'
require 'logger'
require 'ostruct'

require_relative 'configuration_provider'
require_relative 'logging_provider'
require_relative 'state_change'
require_relative 'class_of_service'
require_relative 'kanban_board'

class WorkItem
  include ConfigurationProvider
  include LoggingProvider

  attr_accessor :id, :name, :title, :project, :feature, :release, :tags, :state_changes,
                :defect_count, :defects_status, :story_points, :current_state, :kanban_field,
                :creation_date

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
    # This is the same as map { |sc| sc.user }
    @state_changes.map(&:user).uniq.length
  end

  def blocked_hours
    blocked = 0
    @state_changes.each do |sc|
      if sc.blocked_flag
        blocked += sc.valid_to - sc.valid_from
      end
    end

    format_number blocked / (60 * 60)
  end

  def state_change_violations
    changes = @state_changes.map { |x| get_state_weighting(x.state) }
    change_deltas = changes.each_cons(2).map { |a, b| b - a }
    result = change_deltas.reject { |x| (0..1).member? x || x == -100 }
    result.length
  end

  def format_number(value)
    '%5.3f' % value.abs
  end

  # TODO: use a map to create this rather than loop manually
  def status_counts
    status_map = aggregate_statuses

    statuses = []
    status_map.keys.each do |key|
      s = OpenStruct.new
      s.name = key
      s.value = format_number(status_map[key])

      statuses << s
    end
    statuses
  end

  def aggregate_statuses
    @aggregated_statuses ||= create_aggregated_statuses
  end

  def hours_between(time1, time2)
    (time2 - time1) / 1.hour
  end

  def create_aggregated_statuses
    status_map = {}
    @state_changes.each do |sc|
      status_group = get_canonical_state(get_state_weighting(sc.state))
      next if %w(None Accepted Rejected).member? status_group
      status_map[status_group] ||= 0
      status_map[status_group] += (sc.valid_to - sc.valid_from) / 3600.0
    end
    status_map
  end

  def get_canonical_state(weight)
    case weight
      when 1
        'Ready'
      when 2
        'Design'
      when 3
        'Development'
      when 4
        'Validation'
      when 5
        'Accepted'
      when -100
        'Rejected'
      else
        'Rally Create'
    end
  end

  def get_state_weighting(state)
    case state
      when 'Ready', 'Requirements'
        1
      when 'Design', 'Wireframes', 'Contracts'
        2
      when 'Development', 'Proof of Concept', 'Production Ready'
        3
      when 'Validation', 'Deployment'
        4
      when 'Accepted'
        5
      when 'Rejected'
        -100
      else
        0
    end
  end

  # mode -> most common result
  Enumerable.class_eval do
    def mode
      group_by do |e|
        e
      end.values.max_by(&:size).first
    end
  end

  def dev_lead
    extract_state_changes_data('Development', proc { |x| x.mode.user })
  end

  def qa_lead
    extract_state_changes_data('Validation', proc { |x| x.mode.user })
  end

  # TODO: make sure ready=true in last validation state
  def made_ready_in_validation
    extract_state_changes_data('Validation', proc { |x| x.last.user })
  end

  def ready_date
    story_dates['Ready']
  end

  def design_date
    story_dates['Design']
  end

  def development_date
    story_dates['Development']
  end

  def validation_date
    story_dates['Validation']
  end

  def accepted_date
    story_dates['Accepted']
  end

  def rejected_date
    story_dates['Rejected']
  end

  def story_dates
    @dates ||= Hash[%w(Ready Design Development Validation Accepted Rejected).map { |s| [s, from_date_for_state(@state_changes.find { |x| x.state == s })] }]
  end

  def from_date_for_state(state)
    state ? state.valid_from : nil
  end

  def extract_state_changes_data(target_state, extract)
    state_work = @state_changes.select { |x| x.state == target_state }
    if state_work.empty?
      result = 'N/A'
    else
      result = extract.call state_work
      log.debug "Got #{result} as #{target_state} date/user"
    end
    result
  end

  # extract into factory, will need to set all these variables though

  def create_item(raw_data)
    fail "rawData is not a Hash, it's a #{raw_data.class}" unless raw_data.is_a? Hash

    # log.debug "Raw data: #{JSON.pretty_generate(rawData)}"

    parsed_data = JSON.dump(raw_data.fetch(:detail))
    data = JSON.parse(parsed_data).first

    @id = data.fetch 'FormattedID'
    @name = data.fetch '_refObjectName'
    @story_points = data.fetch 'PlanEstimate'
    @kanban_field = raw_data.fetch :kanban_field_name
    @creation_date = data.fetch 'CreationDate'
    @current_state = data.fetch @kanban_field

    @project = get_item_name_or_nil data, 'Project'
    @release = get_item_name_or_nil data, 'Release'
    @feature = get_item_name_or_nil data, 'PortfolioItem'

    defects = data.fetch('Defects', nil)
    @defect_count = defects ? defects.fetch('Count') : 0

    @defects_status = defects ? data.fetch('DefectStatus') : nil

    create_tags data
    create_state_changes raw_data
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

  def create_state_changes(raw_data)
    lookback_data = raw_data[:lookback]

    parsed_data = JSON.dump(lookback_data)
    data = JSON.parse(parsed_data)

    @state_changes = data.map do |change|
      sc = StateChange.new
      sc.object_id = change['ObjectId'].to_s
      sc.release = change['Release'].to_s
      sc.valid_from = change['_ValidFrom'].to_s
      sc.valid_to = change['_ValidTo'].to_s
      sc.blocked_flag = change['Blocked']
      sc.ready_flag = change['Ready']
      sc.user = change['_User'].to_s
      sc.state = change[@kanban_field].to_s

      sc #TODO: get rid of this temporary 'sc' object, maybe take a hash of options
    end
  end

  def initialize(raw_data)
    create_item raw_data
  end
end
