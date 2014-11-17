require_relative 'spec_helper'
require_relative 'capture'
require_relative '../lib/configuration_factory'
require_relative '../lib/data_access/jira_work_item_lookup'
require_relative '../lib/jira_work_item_factory'

describe 'Jira work item factory' do
  before :all do
    Capture.argv(%w(--system Jira)) do
      ConfigurationFactory.reset
    end
  end

  before :each do
    @lookup = JiraWorkItemLookup.new
    @factory = JiraWorkItemFactory.new
  end

  it 'should get data' do
    id = 'GT-4'
    VCR.use_cassette("#{id}-details", :record => :new_episodes) do
      lookup_data = @lookup.get_data id
      work_item = @factory.create lookup_data
      expect(work_item.id).to eql(id)
      [:name, :title, :project, :current_state, :kanban_field,
       :creation_date, :schedule_dates, :state_changes].each do |i|
        value = work_item.send(i)
        expect(value).not_to be_nil, "expected work item property '#{i}' to have a value ('#{value}'), but got nil"
      end

      # feature -- sub-tasks?
      [:feature, :release, :tags, :defect_count, :defects_status, :story_points].each do |i|
        value = work_item.send(i)
        expect(value).to be_nil, "expected work item property '#{i}' to be nil, but got #{value}"
      end
    end
  end

  after :all do
    ConfigurationFactory.reset
  end
end