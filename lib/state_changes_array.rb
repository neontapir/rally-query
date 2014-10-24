require 'json'
require 'ostruct'

require_relative 'logging_provider'
require_relative 'state_change'

class StateChangeArray < Array
  include LoggingProvider

  def initialize(raw_data, kanban_field)
    lookback_data = raw_data[:lookback]

    parsed_data = JSON.dump(lookback_data)
    data = JSON.parse(parsed_data)

    changes = data.map do |change|
      sc = StateChange.new
      sc.object_id = change['ObjectId'].to_s
      sc.release = change['Release'].to_s
      sc.valid_from = change['_ValidFrom'].to_s
      sc.valid_to = change['_ValidTo'].to_s
      sc.blocked_flag = change['Blocked']
      sc.ready_flag = change['Ready']
      sc.user = change['_User'].to_s
      sc.schedule_state = map_schedule_state(change['ScheduleState'])
      sc.state = change[kanban_field].to_s

      sc #TODO: get rid of this temporary 'sc' object, maybe take a hash of options
    end

    super(changes)
  end

  def map_schedule_state(state)
    case state
      when 208717799
        'Requested'
      when 208717800
        'Defined'
      when 208717801
        'In Progress'
      when 208717802
        'Completed'
      when 208717803
        'Accepted'
      else
        state.to_s
    end
  end

  def extract_state_changes_data(target_state, extract)
    state_work = self.select { |x| x.state == target_state }
    if state_work.empty?
      result = 'N/A'
    else
      result = extract.call state_work
      log.debug "Got #{result} as #{target_state} date/user"
    end
    result
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

  def story_dates
    valid_states = %w(Ready Design Development Validation Accepted Rejected)
    transitions = valid_states.map do |s|
      [s, from_date_for_state(self.find { |x| x.state == s })]
    end
    @dates ||= Hash[transitions]
  end

  def schedule_state_dates
    valid_schedule_state = ['Requested', 'Design', 'In Progress', 'Completed', 'Accepted']
    transitions = valid_schedule_state.map do |s|
      [s, from_date_for_state(self.find { |x| x.schedule_state == s })]
    end
    @schedule_dates ||= Hash[transitions]
  end

  def from_date_for_state(state)
    state ? state.valid_from : nil
  end

  def aggregate_statuses
    @aggregated_statuses ||= create_aggregated_statuses
  end

  def create_aggregated_statuses
    status_map = {}
    self.each do |sc|
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

  def state_change_violations
    changes = self.map { |x| get_state_weighting(x.state) }
    change_deltas = changes.each_cons(2).map { |a, b| b - a }
    result = change_deltas.reject { |x| (0..1).member? x || x == -100 }
    result.length
  end

  def blocked_hours
    blocked = 0
    self.each do |sc|
      if sc.blocked_flag
        blocked += sc.valid_to - sc.valid_from
      end
    end

    format_number blocked / (60 * 60)
  end

  def format_number(value)
    '%5.3f' % value.abs
  end
end