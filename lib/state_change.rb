require 'pstore'
require 'time'
require_relative 'data_access/rally_work_item_lookup'

class StateChange
  attr_reader :release, :user, :valid_from, :valid_to
  attr_accessor :object_id, :blocked_flag, :ready_flag, :state, :schedule_state

  def initialize(pstore_location = 'data.pstore', lookup = RallyWorkItemLookup.new)
    @@store ||= PStore.new(pstore_location)
    @lookup = lookup
  end

  def release=(value)
    @release = nil
  end

  def user=(value)
    @user = value
  end

  def valid_from=(value)
    @valid_from = Time.parse value
  end

  def valid_to=(value)
    date = Time.parse value
    @valid_to = [Time.new, date].min
  end

  private

  def to_s
    "#{@state}: #{@valid_from} to #{@valid_to}"
  end
end