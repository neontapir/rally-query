require 'rspec'
require 'spec_helper'
require 'vcr'
require_relative '../lib/work_item_detailer'
require_relative '../lib/work_item'

describe 'Work item without Kanban board' do
  before :all do
    detailer = WorkItemDetailer.new
    id = 'US56682'
    VCR.use_cassette("#{id}-details", :record => :new_episodes) do
      @results = detailer.get_data id
    end
    @work_item = WorkItem.new(@results)
  end

  it 'should have the story ID' do
    expect(@work_item.id).to eq('US56682')
  end

  it 'should have the story name' do
    expect(@work_item.name).to eq('Support - Vendor Pool Adds Not Functioning')
  end

  it 'should have the project name' do
    expect(@work_item.project).to eq('CCX Team')
  end

  it 'should not have a release name' do
    expect(@work_item.release).to be_nil
  end

  it 'should have no tags' do
    expect(@work_item.tags).to eq('')
  end

  it 'should have zero blocked hours' do
    expect(@work_item.blocked_hours.to_f).to be(0.0)
  end

  it 'should have statuses' do
    # should have Rally Create
    expect(@work_item.status_counts.length).to eql(1)
  end

  it 'should have schedule states' do
    expect(@work_item.schedule_state_dates.length).to eq(5)
    expect(@work_item.schedule_state_dates['Requested'].to_s).to eql("2014-10-16 18:05:11 UTC")
  end
end