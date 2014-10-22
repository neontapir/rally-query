require 'rspec'
require 'spec_helper'
require 'vcr'
require_relative '../lib/release_detailer'
require_relative 'vcr_setup'

describe 'Release detailer' do
  before :each do
    @detailer = ReleaseDetailer.new
  end

  it 'should get user stories' do
    id = 'INSX BETA'
    VCR.use_cassette("insx-beta-release-details", :record => :new_episodes) do
      results = @detailer.get_work_items id
      expect(results).to include "US52286"
    end
  end

  it 'should get portfolio items' do
    id = 'ODAP'
    VCR.use_cassette("odap-details", :record => :new_episodes) do
      results = @detailer.get_portfolio_items id
      expect(results).to include "F3969"
    end
  end
end
