require 'pstore'
require 'time'
require_relative 'data_access/rally_work_item_lookup'
require_relative 'state_change'

class RallyStateChange < StateChange
  attr_reader :release, :user, :valid_from, :valid_to
  attr_accessor :object_id, :blocked_flag, :ready_flag, :state, :schedule_state

  def initialize(pstore_location = 'data.pstore', lookup = RallyWorkItemLookup.new)
    @@store ||= PStore.new(pstore_location)
    @lookup = lookup
  end

  def release=(value)
    set_to = proc { |v| @release = v }
    data_lookup = proc { |lookup, v| lookup.get_release v }
    name_lookup = proc { |release| release['Name'] }
    store_value(value, set_to, 'releases-', data_lookup, name_lookup)
  end

  def user=(value)
    set_to = proc { |v| @user = v }
    data_lookup = proc { |lookup, v| lookup.get_user v }
    name_lookup = proc { |user| user['DisplayName'] || "#{user['FirstName']} #{user['LastName']}" }
    store_value(value, set_to, 'users-', data_lookup, name_lookup)
  end

  private

  def store_value(value, set_to, key_prefix, data_lookup, name_lookup)
    if value.to_s.empty?
      set_to.call 'None'
    else
      store_key = key_prefix + value
      stored_item = @@store.transaction do
          @@store[store_key]
        end
      if stored_item.to_s.empty?
        item = data_lookup.call(@lookup, value)
        name = name_lookup.call item
        @@store.transaction do
          @@store[store_key] = name
        end
        set_to.call name
      else
        set_to.call stored_item
      end
    end
  end
end