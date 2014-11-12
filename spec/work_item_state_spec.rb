require_relative 'spec_helper'
require_relative '../lib/work_item_state'

describe 'Work item state' do
  it 'should convert to string' do
    expect(WorkItemState.rally_create.to_s).to eq('Rally Create')
  end

  it 'should convert to integer' do
    expect(WorkItemState.rally_create.to_i).to eq(0)
  end

  it 'should find a canonical state by name' do
    expect(WorkItemState.find_by_name('Requirements')).to eq(WorkItemState.ready)
  end

  it 'should return None if no canonical state found' do
    expect(WorkItemState.find_by_name('xyzzy')).to eq(WorkItemState.none)
  end

  STATES = [WorkItemState.none] + WorkItemState.statuses

  it 'should have a lookup method for each canonical state' do
    STATES.each do |s|
      work_item_state = WorkItemState.send(s.state)
      expect(work_item_state.state).to eql(s.state)
      expect(work_item_state.weight.to_i).to be_truthy
    end
  end

  it 'should be able to find each canonical state name' do
    STATES.each do |s|
      expect(WorkItemState.find_by_name(s.state.to_s.capitalize)).to eql(s)
    end
  end
end