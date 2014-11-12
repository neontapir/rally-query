require_relative 'spec_helper'
require_relative '../lib/data_access/rally_work_item_detailer'
require_relative '../lib/state_change'
require_relative '../lib/rally_work_item_factory'

# These tests were added afterward, so I create StateChanges piggybacking off the WorkItem.create_state_changes method

describe 'State changes for work item US53364' do
  before :all do
    work_item_detailer = RallyWorkItemDetailer.new
    id = 'US53364'
    VCR.use_cassette("#{id}-details", :record => :new_episodes) do
      @results = work_item_detailer.get_data id
    end
    @work_item = RallyWorkItemFactory.create(@results)
  end

  it 'should have state changes' do
    expect(@work_item.state_changes).not_to be_empty
  end

  it 'should have last state change with a release' do
    expect(@work_item.state_changes.last.release).to eq('INSX BETA')
  end

  it 'should have last state change with a schedule state' do
    expect(@work_item.state_changes.last.schedule_state).to eq('Accepted')
  end

  it 'should have two users' do
    expect(@work_item.users).to be(2)
  end
end

describe 'State changes for work item DE7477' do
  before :all do
    work_item_detailer = RallyWorkItemDetailer.new
    @id = 'DE7477'
    VCR.use_cassette("#{@id}-details", :record => :new_episodes) do
      @results = work_item_detailer.get_data @id
      @work_item = RallyWorkItemFactory.create(@results)
    end
  end

  it 'should have one state change violation' do
    expect(@work_item.state_change_violations).to eq(1)
  end

  # Tam Nguyen has a DisplayName of nil in Rally as of the time of the VCR capture
  it 'should have the three expected users' do
    expect(@work_item.state_changes.map(&:user).uniq).to match_array ['Daniel Milburn', 'Chuck Durfee', 'Tam Nguyen']
  end
end
