require 'rspec'
require_relative '../work_item_state'

describe 'Work item state' do
  it 'should convert to string' do
    expect(WorkItemState.rally_create.to_s).to eq('Rally Create')
  end

  it 'should convert to integer' do
    expect(WorkItemState.rally_create.to_i).to eq(0)
  end

  it 'should convert to canonical state' do
    expect(WorkItemState.find_by_name('Requirements')).to eq(WorkItemState.ready)
  end
end