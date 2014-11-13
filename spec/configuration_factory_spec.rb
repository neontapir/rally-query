require 'configatron'
require_relative 'spec_helper'
require_relative '../lib/configuration_factory'

describe 'Configuration factory' do
  it 'should create a valid configuration' do
    ConfigurationFactory.create
    [:options, :credentials, :system, :rally_workspace, :formatter, :stories, :log_level].each do |m|
      expect(configatron.has_key? m).to be_truthy
    end
  end
end