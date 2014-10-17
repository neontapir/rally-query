require 'rspec'
require 'spec_helper'
require 'vcr'
require_relative '../rally_project_query'
require_relative '../vcr_setup'

describe 'Rally project query object' do
  before :each do
    @query = RallyProjectQuery.new
  end

  it 'should get story IDs by name' do
    release_name = 'EGX - GUI'
    VCR.use_cassette("egx-gui-project") do
      details = @query.get_raw_story_list release_name
      expect(details.code).to eq(200)
    end
  end
end
