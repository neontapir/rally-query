require_relative '../lib/work_item_analysis_format'

describe 'Work Item Analysis Format' do
  before :each do
    @format = WorkItemAnalysisFormat.new
  end

  it 'should not be nil' do
    expect(@format).not_to be_nil
  end
end