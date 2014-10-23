require_relative '../lib/work_item_basic_format'

describe 'Work Item Basic Format' do
  before :each do
    @format = WorkItemBasicFormat.new
  end

  it 'should not be nil' do
    expect(@format).not_to be_nil
  end
end