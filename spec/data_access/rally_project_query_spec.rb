require_relative '../spec_helper'
require_relative '../../lib/configuration_factory'
require_relative '../../lib/data_access/rally_project_query'


describe 'Rally project query object' do
  before :all do
    ConfigurationFactory.ensure
  end

  before :each do
    @query = RallyProjectQuery.new
  end

  it 'should get story IDs by name' do
    release_name = 'EGX - GUI'
    VCR.use_cassette("egx-gui-project", :record => :new_episodes) do
      details = @query.get_raw_story_list release_name
      expect(details.code).to eq(200)
    end
  end
end
