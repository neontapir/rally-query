require_relative '../spec_helper'
require_relative '../../lib/configuration_factory'
require_relative '../../lib/data_access/rally_detail_query'

describe 'Rally detail query object' do
  before :all do
    ConfigurationFactory.ensure
  end

  before :each do
    @query = RallyDetailQuery.new
  end

  it 'should canonize a work item identifier' do
    test_cases = {
        'US12345' => 'US12345',
        'DE9876' => 'DE9876',
        '23456' => 'US23456',
        'xyzzy' => nil,
    }
    test_cases.keys.each do |testCase|
      expect(@query.canonize(testCase)).to eq(test_cases[testCase])
    end
  end

  it 'should return the right identifier for each work item' do
    test_cases = {
        'US12345' => 'hierarchicalrequirement',
        'DE9876' => 'defect',
        '23456' => nil
    }
    test_cases.keys.each do |testCase|
      expect(@query.item_type_identifier(testCase)).to eq(test_cases[testCase])
    end
  end

  it "should connect to Rally's detail API" do
    id = 'US53364'
    VCR.use_cassette("#{id}-details", :record => :new_episodes) do
      details = @query.get_raw_details id
      expect(details.code).to eq(200)
    end
  end

  it 'should get release details by id' do
    id = '18641615604'
    VCR.use_cassette("#{id}-release-details", :record => :new_episodes) do
      details = @query.get_raw_release id
      expect(details.code).to eq(200)
    end
  end

  it 'should get user details by id' do
    id = '13377163924'
    VCR.use_cassette("#{id}-user-details", :record => :new_episodes) do
      details = @query.get_raw_user id
      expect(details.code).to eq(200)
    end
  end

  it 'should get project details by id' do
    id = '18143128574'
    VCR.use_cassette("#{id}-project-details", :record => :new_episodes) do
      details = @query.get_raw_project id
      expect(details.code).to eq(200)
    end
  end

  it 'should get feature details by id' do
    id = '20662787587'
    VCR.use_cassette("#{id}-feature-details", :record => :new_episodes) do
      details = @query.get_raw_feature id
      expect(details.code).to eq(200)
    end
  end
end
