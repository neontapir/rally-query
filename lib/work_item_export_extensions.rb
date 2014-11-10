require 'business_time'

class WorkItem
  def actual_story_points
    @story_points
  end

  def state
    if @current_state.nil? || @current_state == 'None'
      'Rally Create'
    else
      @current_state
    end
  end

  def in_progress
    !(%w(None Accepted Rejected).include? @current_state)
  end

  def design_hours
    return 0 if design_date.nil?
    hours_between design_date, (development_date || Time.now)
  end

  def development_hours
    return 0 if development_date.nil?
    hours_between development_date, (validation_date || Time.now)
  end

  def ready_hours
    return 0 if ready_date.nil?
    hours_between ready_date, (design_date || Time.new(creation_date) || Time.now)
  end

  def validation_hours
    return 0 if validation_date.nil?
    hours_between validation_date, (accepted_date || rejected_date || Time.now)
  end

  def hours_between(time1, time2)
    (time2 - time1).abs / 1.hour
  end

  def adjusted_design_hours
    return 0 if design_date.nil?
    design_date.business_time_until(development_date || Time.now).abs / 1.hour
  end

  def adjusted_development_hours
    return 0 if development_date.nil?
    development_date.business_time_until(validation_date || Time.now).abs / 1.hour
  end

  def adjusted_ready_hours
    return 0 if ready_date.nil?
    ready_date.business_time_until(design_date || Time.new(creation_date) || Time.now).abs / 1.hour
  end

  def adjusted_validation_hours
    return 0 if validation_date.nil?
    validation_date.business_time_until(accepted_date || rejected_date || Time.now).abs / 1.hour
  end

  def adjusted_cycle_time
    [adjusted_ready_hours, adjusted_design_hours, adjusted_development_hours, adjusted_validation_hours].sum
  end

  def ready_date
    @state_changes.kanban_state_dates['Ready'] || design_date
  end

  def design_date
    @state_changes.kanban_state_dates['Design'] || development_date
  end

  def development_date
    @state_changes.kanban_state_dates['Development'] || validation_date
  end

  def validation_date
    @state_changes.kanban_state_dates['Validation'] || accepted_date
  end

  def accepted_date
    @state_changes.kanban_state_dates['Accepted']
  end

  def rejected_date
    @state_changes.kanban_state_dates['Rejected']
  end
end
