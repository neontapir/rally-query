require 'json'
require 'ostruct'

require_relative 'logging_provider'
require_relative 'state_change'
require_relative 'work_item_state'

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
      state = change['ScheduleState']
      sc.schedule_state = SCHEDULE_STATE_STRING[state] || state.to_s
      sc.state = change[kanban_field].to_s

      sc #TODO: get rid of this temporary 'sc' object, maybe take a hash of options
    end

    super(changes)
  end

  SCHEDULE_STATE_STRING = { 208717799 => 'Requested', 208717800 => 'Defined', 208717801 => 'In Progress',
                         208717802 => 'Completed', 208717803 => 'Accepted' }.freeze

  # mode -> most common result
  Enumerable.class_eval do
    def mode
      group_by do |e|
        e
      end.values.max_by(&:size).first
    end
  end

  def dev_lead
    extract_state_changes_data('Development', proc { |sc| sc.mode.user })
  end

  def qa_lead
    extract_state_changes_data('Validation', proc { |sc| sc.mode.user })
  end

  def made_ready_in_validation
    extract_state_changes_data('Validation', proc { |sc| sc.last.user if sc.last.ready_flag })
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

  def kanban_state_dates
    valid_states = %w(Ready Design Development Validation Accepted Rejected)
    @kanban_state_dates ||= date_set(valid_states, proc { |x,s| x.state == s })
  end

  def schedule_state_dates
    group = ['Requested', 'Design', 'In Progress', 'Completed', 'Accepted']
    @schedule_state_dates ||= date_set(group, proc { |x,s| x.schedule_state == s })
  end

  def date_set(group, match)
    Hash[ group.map { |state| [state, from_date_for_state(self.find { |x| match.call x, state })] } ]
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
      state = WorkItemState.find_by_name sc.state
      canonical_state_name = state.to_s
      next if %w(None Accepted Rejected).member? canonical_state_name

      status_map[canonical_state_name] ||= 0
      status_map[canonical_state_name] += (sc.valid_to - sc.valid_from) / 1.hour
    end

    status_map
  end

  def status_counts
    aggregate_statuses.map { |k,v| OpenStruct.new(:name => k, :value => format_number(v)) }.to_a
  end

  def state_change_violations
    changes = self.map { |x| state = WorkItemState.find_by_name x.state
    state.weight }
    change_deltas = changes.each_cons(2).map { |a, b| b - a }
    changes_counting_as_violations = change_deltas.reject{|x| [-100,0,1].member? x}
    changes_counting_as_violations.length
  end

  def blocked_hours
    blocked = self.find_all{|x| x.blocked_flag}.sum{|sc| sc.valid_to - sc.valid_from}
    format_number blocked / 1.hour
  end

  def format_number(value)
    '%5.3f' % value.abs
  end
end