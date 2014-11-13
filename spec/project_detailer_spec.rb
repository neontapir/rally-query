require_relative 'spec_helper'
require_relative 'vcr_setup'
require_relative '../lib/configuration_factory'
require_relative '../lib/project_detailer'

describe 'Project detailer' do
  before :all do
    ConfigurationFactory.create
  end

  before :each do
    @detailer = ProjectDetailer.new
  end

  it 'should get user stories' do
    id = 'EGX - GUI'
    VCR.use_cassette("egx-gui-project-details", :record => :new_episodes) do
      results = @detailer.get_work_items id
      expect(results).to include "US52286"
    end
  end

  it 'should get portfolio items' do
    id = 'EGX - GUI'
    VCR.use_cassette("egx-gui-project-details", :record => :new_episodes) do
      results = @detailer.get_portfolio_items id
      expect(results).to include "F3922"
    end
  end
end
