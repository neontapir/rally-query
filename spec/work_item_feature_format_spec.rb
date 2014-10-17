require_relative '../work_item_feature_format'

describe 'Work Item Feature Format' do
  before :each do
    @format = WorkItemFeatureFormat.new
  end

  it 'should not be nil' do
    expect(@format).not_to be_nil
  end
end
