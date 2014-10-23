require 'mustache'
require_relative 'work_item_base_format'
require_relative '../work_item'

class WorkItemScreenFormat < WorkItemBaseFormat
  attr_accessor :work_items

  def stories
    @work_items.map do |w|
      {
          id: w.id,
          name: w.name,
          project: w.project,
          feature: w.feature,
          release: w.release,
          tags: w.tags,
          keywords: w.keywords,
          state_changes: state_changes(w),
          schedule_state_changes: schedule_state_changes(w),
          state_change_violations: w.state_change_violations,
          user_count: w.users,
          defect_count: w.defect_count,
          defects_status: w.defects_status,
          blocked_hours: w.blocked_hours,
          status_counts: w.status_counts,
      }
    end
  end

  def state_changes(work_item)
    work_item.state_changes.map do |sc|
      {
          release: (sc.release or 'None').ljust(10),
          user: (sc.user or 'None').ljust(20),
          state: state(sc.state).ljust(12),
          valid_from: format_date(sc.valid_from),
          valid_to: format_date(sc.valid_to),
          blocked: blocked(sc.blocked_flag),
          ready: ready(sc.ready_flag),
      }
    end
  end

  def schedule_state_changes(work_item)
    work_item.state_changes.map do |sc|
      {
          user: (sc.user or 'None').ljust(20),
          state: sc.schedule_state.ljust(12),
          valid_from: format_date(sc.valid_from),
          valid_to: format_date(sc.valid_to),
      }
    end
  end

  def blocked(blocked_flag)
    blocked_flag ? 'BLOCKED' : '-------'
  end

  def ready(ready_flag)
    ready_flag ? 'READY' : '-----'
  end

  def state(state_value)
    state_value.empty? ? 'None' : state_value
  end
end
