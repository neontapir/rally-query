require_relative 'spec_helper'
require_relative '../lib/release_lookup'

describe 'Release lookup' do
  before :all do
    ConfigurationFactory.ensure
  end

  def lookup
    ReleaseLookup.new
  end

  it 'should get user stories' do
    VCR.use_cassette("insx-beta-release-details", :record => :new_episodes) do
      results = lookup.get_work_items 'INSX BETA'
      expect(results).to include "US52286"
    end
  end

  it 'should get portfolio items' do
    VCR.use_cassette("odap-details", :record => :new_episodes) do
      results = lookup.get_portfolio_items 'ODAP'
      expect(results).to include "F3969"
    end
  end
end
