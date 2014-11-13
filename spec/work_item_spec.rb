require_relative 'spec_helper'
require_relative '../lib/configuration_factory'
require_relative '../lib/data_access/rally_work_item_detailer'
require_relative '../lib/rally_work_item_factory'

describe 'Work item' do
  before :all do
    ConfigurationFactory.create
    @detailer = RallyWorkItemDetailer.new
  end

  def fetch_work_item(id)
    VCR.use_cassette("#{id}-details", :record => :new_episodes) do
      results = @detailer.get_data id
      @work_item = RallyWorkItemFactory.create(results)
    end
  end

  context 'Work item with Kanban board' do
    before :all do
      fetch_work_item 'US53364'
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
      expect(@work_item.status_counts.length).to eq(4)
    end

    it 'should have schedule state dates' do
      expect(@work_item.schedule_requested_date.to_s).to eql("2014-06-06 16:07:12 UTC")
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

  context 'without Kanban board' do
    before :all do
      fetch_work_item 'US56682'
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
      expect(@work_item.status_counts.length).to eql(0)
    end

    it 'should have schedule state dates' do
      expect(@work_item.schedule_requested_date.to_s).to eql("2014-10-16 18:05:11 UTC")
    end
  end

  context 'on GUI board' do
    before :all do
      @id = 'US52746'
      release_id = '18641616440'
      VCR.use_cassette("#{release_id}-release-details", :record => :new_episodes) do
        VCR.use_cassette("#{@id}-details", :record => :new_episodes) do
          results = @detailer.get_data @id
          @work_item = RallyWorkItemFactory.create(results)
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

  context 'with blocked hours' do
    before :all do
      fetch_work_item 'US51735'
    end

    it 'should have some blocked hours' do
      expect(@work_item.blocked_hours.to_f).to be_between(41.541, 41.542)
    end
  end

  context 'defect in ready state' do
    before :all do
      fetch_work_item 'DE7477'
    end

    it 'should have no blocked hours' do
      expect(@work_item.blocked_hours.to_f).to eq(0.0)
    end
  end
end