require_relative 'spec_helper'
require_relative '../lib/configuration_factory'

describe 'Configuration factory' do
  it 'should create a valid configuration' do
    config = ConfigurationFactory.create
    expect(config).not_to be_nil
    [:options, :credentials, :system, :rally_workspace, :formatter, :stories, :log_level].each do |m|
      expect(config.has_key? m).to be_truthy
    end
  end
end