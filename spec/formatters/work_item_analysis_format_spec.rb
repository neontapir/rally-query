require_relative '../spec_helper'
require_relative '../../lib/formatters/work_item_analysis_format'

describe WorkItemAnalysisFormat do
  it 'should not be nil' do
    expect(subject).not_to be_nil
  end
end