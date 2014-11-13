require_relative 'spec_helper'
require_relative '../lib/work_item_state'

describe 'Work item state' do
  context 'Rally create' do
    subject { WorkItemState.rally_create }

    it 'should convert to string' do
      expect(subject.to_s).to eq('Rally Create')
    end

    it 'should convert to integer' do
      expect(subject.to_i).to eq(0)
    end
  end

  it 'should find a canonical state by name' do
    expect(WorkItemState.find_by_name('Requirements')).to eq(WorkItemState.ready)
  end

  it 'should return None if no canonical state found' do
    expect(WorkItemState.find_by_name('xyzzy')).to eq(WorkItemState.none)
  end

  context 'lookup' do
    CANONICAL_STATES = [WorkItemState.none] + WorkItemState.statuses

    it 'should find each canonical state' do
      CANONICAL_STATES.each do |s|
        work_item_state = WorkItemState.send(s.state)
        expect(work_item_state.state).to eql(s.state)
        expect(work_item_state.weight.to_i).to be_truthy
      end
    end

    it 'should find each canonical state name' do
      CANONICAL_STATES.each do |s|
        expect(WorkItemState.find_by_name(s.state.to_s.capitalize)).to eql(s)
      end
    end
  end
end