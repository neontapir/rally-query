require_relative '../../lib/formatters/work_item_export_format'

describe 'Work Item Export Format' do
  before :each do
    @format = WorkItemExportFormat.new
  end

  it 'should not be nil' do
    expect(@format).not_to be_nil
  end
end
