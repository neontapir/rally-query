require 'rspec'
require_relative 'capture'
require_relative '../configuration_provider'
require_relative '../work_item_export_format'

include ConfigurationProvider

describe 'Default configuration provider' do
  it 'should provide configuration' do
    expect(configuration).not_to be_nil
    expect(configuration.log_level).to eq(Logger::INFO)
  end
end

describe 'Configuration provider with arguments' do
  it 'should allow debug logging capability' do
    Capture.argv(%w(--debug)) do
      configuration = Configuration.new
      expect(configuration.log_level).to eq(Logger::DEBUG)
    end
  end

  it 'should allow export capability' do
    Capture.argv(%w(--export)) do
      configuration = Configuration.new
      expect(configuration.formatter).to eq('WorkItemExportFormat')
    end
  end

  it 'should allow screen render capability' do
    Capture.argv(%w(--screen)) do
      configuration = Configuration.new
      expect(configuration.formatter).to eq('WorkItemScreenFormat')
    end
  end

  it 'should get list of stories' do
    Capture.argv(%w(--debug 12345 DE9876)) do
      configuration = Configuration.new
      # expect(configuration.options.to_hash.to_s).to eq(nil)
      expect(configuration.log_level).to eq(Logger::DEBUG)
      expect(configuration.stories).to match_array(%w(12345 DE9876))
    end
  end
end
