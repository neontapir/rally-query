require_relative 'spec_helper'

require_relative '../lib/configuration_factory'
require_relative '../lib/project_lookup'

describe 'Project lookup' do
  before :all do
    ConfigurationFactory.ensure
  end

  def lookup
    ProjectLookup.new
  end

  ID = 'EGX - GUI'

  it 'should get user stories' do
    VCR.use_cassette("egx-gui-project-details", :record => :new_episodes) do
      results = lookup.get_work_items ID
      expect(results).to include "US52286"
    end
  end

  it 'should get portfolio items' do
    VCR.use_cassette("egx-gui-project-details", :record => :new_episodes) do
      results = lookup.get_portfolio_items ID
      expect(results).to include "F3922"
    end
  end
end
