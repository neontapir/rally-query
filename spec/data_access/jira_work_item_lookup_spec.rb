require_relative '../../spec/spec_helper'
require_relative '../../lib/data_access/jira_work_item_lookup'

describe 'Jira work item lookup' do
  before :all do
    Capture.argv(%w(--system Jira)) do
      ConfigurationFactory.reset
    end
  end

  before :each do
    @lookup = JiraWorkItemLookup.new
  end

  it 'should get data' do
    id = 'GT-4'
    VCR.use_cassette("#{id}-details", :record => :new_episodes) do
      results = @lookup.get_data id
      expect(results.to_s).to match /#{id}/
    end
  end

  after :all do
    ConfigurationFactory.reset
  end
end