require_relative '../spec_helper'
require_relative '../vcr_setup'
require_relative '../../lib/data_access/rally_release_query'

describe 'Rally release query object' do
  before :each do
    @query = RallyReleaseQuery.new
  end

  it 'should get story IDs by name' do
    release_name = 'INSX BETA'
    VCR.use_cassette("insx-beta-release", :record => :new_episodes) do
      details = @query.get_raw_story_list release_name
      expect(details.code).to eq(200)
    end
  end
end
