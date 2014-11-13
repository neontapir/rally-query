require_relative '../../spec/spec_helper'

require_relative '../../lib/configuration_factory'
require_relative '../../lib/data_access/rally_work_item_detailer'


describe 'Get story details' do
  before :all do
    ConfigurationFactory.ensure
  end

  before :each do
    @work_item_detailer = RallyWorkItemDetailer.new
  end

  it 'should get details of a user story' do
    id = 'US53364'
    VCR.use_cassette("#{id}-details", :record => :new_episodes) do
      results = @work_item_detailer.get_detail id
      expect(results.to_s).to match /#{id}/
    end
  end

  it 'should get details of a user story with no prefix' do
    id = '53364'
    expected = 'US'+id
    VCR.use_cassette("#{expected}-details", :record => :new_episodes) do
      results = @work_item_detailer.get_detail id
      expect(results.to_s).to match /#{expected}/
    end
  end

  it 'should get details of a defect' do
    id = 'DE7477'
    VCR.use_cassette("#{id}-details", :record => :new_episodes) do
      results = @work_item_detailer.get_detail id
      expect(results.to_s).to match /#{id}/
    end
  end

  it 'should get the lookback of a user story' do
    id = 'US53364'
    story_object_id = '19579322489'
    project = 'EGX - Backend' # comes from details query
    VCR.use_cassette("#{id}-lookback", record: :new_episodes, match_requests_on: [:method, :uri, :body]) do
      results = @work_item_detailer.get_lookback id, project
      expect(results.to_s).to match /#{story_object_id}/
    end
  end

  it 'should get the data of a user story' do
    id = 'US53364'
    story_object_id = '19579322489'
    VCR.use_cassette("#{id}-details") do
      VCR.use_cassette("#{id}-lookback", record: :new_episodes, match_requests_on: [:method, :uri, :body]) do
        results = @work_item_detailer.get_data id
        expect(results.is_a? Hash).to be_truthy
        expect(results[:detail].to_s).to match /#{id}/
        expect(results[:lookback].to_s).to match /#{story_object_id}/
      end
    end
  end

  it 'should get the release name from a release query' do
    release_id = '18641615604'
    VCR.use_cassette("#{release_id}-release-details", :record => :new_episodes) do
      results = @work_item_detailer.get_release release_id
      expect(results['Name'].to_s).to eq('INSX ALPHA')
    end
  end

  it 'should get the user name from a user query' do
    user_id = '13377163924'
    VCR.use_cassette("#{user_id}-user-details", :record => :new_episodes) do
      results = @work_item_detailer.get_user user_id
      expect(results['DisplayName'].to_s).to eq('Jon Jenkins')
    end
  end
end
