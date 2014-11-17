require 'configatron'
require 'logger'
require 'slop'

require_relative 'spec_helper'
require_relative 'capture'
require_relative '../lib/configuration_factory'

describe 'Configuration factory' do
  it 'should create a valid configuration' do
    ConfigurationFactory.ensure
    [:logger, :options, :credentials, :system, :rally_workspace, :formatter, :stories, :log_level].each do |m|
      expect(configatron.has_key? m).to be_truthy
    end
    expect(configatron.logger).is_a? Logger
    expect(configatron.stories).is_a? Array
  end

  context 'with reset' do
    it 'should re-read configuration options' do
      configatron.temp do
        expect(configatron.options.feature?).to be_falsey
        Capture.argv(%w(--feature)) do
          expect(ARGV).to include '--feature'
          ConfigurationFactory.reset
          expect(configatron.options.feature?).to be_truthy
        end
      end
    end
  end
end