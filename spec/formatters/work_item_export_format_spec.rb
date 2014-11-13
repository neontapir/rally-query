require_relative '../spec_helper'
require_relative '../../lib/formatters/work_item_export_format'

describe WorkItemExportFormat do
  it 'should not be nil' do
    expect(subject).not_to be_nil
  end
end
