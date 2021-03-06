require_relative 'spec_helper'
require_relative '../lib/configuration_factory'
require_relative '../lib/data_access/rally_work_item_lookup'
require_relative '../lib/rally_work_item_factory'

describe 'Work item without Kanban board' do
  let(:work_item) do
    ConfigurationFactory.ensure
    lookup = RallyWorkItemLookup.new
    id = 'US56682'
    VCR.use_cassette("#{id}-details", :record => :new_episodes) do
      @results = lookup.get_data id
    end
    factory = RallyWorkItemFactory.new
    factory.create @results
  end

  it 'should have the story ID' do
    expect(work_item.id).to eq('US56682')
  end

  it 'should have the story name' do
    expect(work_item.name).to eq('Support - Vendor Pool Adds Not Functioning')
  end

  it 'should have the project name' do
    expect(work_item.project).to eq('CCX Team')
  end

  it 'should not have a release name' do
    expect(work_item.release).to be_nil
  end

  it 'should have no tags' do
    expect(work_item.tags).to eq('')
  end

  it 'should have zero blocked hours' do
    expect(work_item.blocked_hours.to_f).to be(0.0)
  end

  it 'should have statuses' do
    expect(work_item.status_counts.length).to eql(0)
  end

  it 'should have schedule state dates' do
    expect(work_item.schedule_requested_date.to_s).to eql("2014-10-16 18:05:11 UTC")
  end
end