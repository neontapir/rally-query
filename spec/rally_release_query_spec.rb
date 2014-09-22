require 'rspec'
require 'spec_helper'
require 'vcr'
require_relative '../rally_release_query'
require_relative '../vcr_setup'

describe 'Rally release query object' do
  before :each do
    @query = RallyReleaseQuery.new
  end

  it 'should get story IDs by name' do
    release_name = 'INSX BETA'
    VCR.use_cassette("insx-beta-release") do
      details = @query.get_raw_story_list release_name
      expect(details.code).to eq(200)
    end
  end
end