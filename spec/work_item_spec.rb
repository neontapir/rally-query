require 'rspec'
require 'spec_helper'
require 'vcr'
require_relative '../lib/work_item_detailer'
require_relative '../lib/work_item'

describe 'Work item US53364' do
  before :all do
    detailer = WorkItemDetailer.new
    id = 'US53364'
    VCR.use_cassette("#{id}-details", :record => :new_episodes) do
      @results = detailer.get_data id
    end
    @work_item = WorkItem.new(@results)
  end

  it 'should have the story ID' do
    expect(@work_item.id).to eq('US53364')
  end

  it 'should have the story name' do
    expect(@work_item.name).to eq('DREV: Validate 2A Traffic via the Document Simulator')
  end

  it 'should have the project name' do
    expect(@work_item.project).to eq('EGX - R&D')
  end

  it 'should have the release name' do
    expect(@work_item.release).to eq('INSX BETA')
  end

  it 'should have no tags' do
    expect(@work_item.tags).to eq('')
  end

  it 'should have zero blocked hours' do
    expect(@work_item.blocked_hours.to_f).to be(0.0)
  end

  it 'should have statuses' do
    #expected = "[#<struct name=\"Ready\", value=2.76>, #<struct name=\"Design\", value=2.302>, #<struct name=\"Development\", value=269041.526>, #<struct name=\"Validation\", value=2008.868>"
    expect(@work_item.status_counts.length).to eq(5)
  end

  it 'should have two users' do
    expect(@work_item.users).to eq(2)
  end

  it 'should have no state change violations' do
    expect(@work_item.state_change_violations).to eq(0)
  end

  it 'should have a created date of ...' do
    expect(@work_item.creation_date).to eq('2014-06-06T16:07:12.328Z')
  end
end

describe 'Work item US52746' do
  before :all do
    detailer = WorkItemDetailer.new
    @id = 'US52746'
    @release_id = '18641616440'
    VCR.use_cassette("#{@release_id}-release-details", :record => :new_episodes) do
      VCR.use_cassette("#{@id}-details", :record => :new_episodes) do
        @results = detailer.get_data @id
        @work_item = WorkItem.new(@results)
      end
    end
  end

  it 'should have the story ID' do
    expect(@work_item.id).to eq(@id)
  end

  it 'should have the GUI tag' do
    expect(@work_item.tags).to eq('GUI')
  end
end

describe 'Work item US51735' do
  before :all do
    detailer = WorkItemDetailer.new
    @id = 'US51735'
    VCR.use_cassette("#{@id}-details", :record => :new_episodes) do
      @results = detailer.get_data @id
      @work_item = WorkItem.new(@results)
    end
  end

  it 'should have some blocked hours' do
    expect(@work_item.blocked_hours.to_f).to be_between(41.541, 41.542)
  end
end

describe 'Work item DE7477' do
  before :all do
    detailer = WorkItemDetailer.new
    @id = 'DE7477'
    VCR.use_cassette("#{@id}-details", :record => :new_episodes) do
      @results = detailer.get_data @id
      @work_item = WorkItem.new(@results)
    end
  end

  it 'should have no blocked hours' do
    expect(@work_item.blocked_hours.to_f).to eq(0.0)
  end
end
