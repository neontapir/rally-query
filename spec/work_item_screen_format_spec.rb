require_relative '../work_item_screen_format'

describe 'Work Item Screen Format' do
  before :each do
    @format = WorkItemScreenFormat.new
  end

  it 'should not be nil' do
    expect(@format).not_to be_nil
  end
end
