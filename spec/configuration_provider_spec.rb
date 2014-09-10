require 'rspec'

require_relative '../configuration_provider'
require_relative '../work_item_export_format'

describe 'Configuration provider', broken: true do
  include ConfigurationProvider

  it 'should provide configuration' do
    expect(configuration).not_to be_nil
    expect(configuration.log_level).to eq(Logger::INFO)
  end

  it 'should allow debug logging capability' do
    Capture.argv(%w(--debug)) do
      expect(configuration.log_level).to eq(Logger::DEBUG)
    end
  end

  it 'should allow export capability' do
    Capture.argv(%w(--export)) do
      expect(configuration.formatter).to eq('WorkItemExportFormat')
    end
  end

  it 'should allow screen render capability' do
    Capture.argv(%w(--screen)) do
      expect(configuration.formatter).to eq('WorkItemScreenFormat')
    end
  end

  it 'should get list of stories' do
    Capture.argv(%w(--debug 12345 DE9876)) do
      # expect(configuration.options.to_hash.to_s).to eq(nil)
      expect(configuration.log_level).to eq(Logger::DEBUG)
      expect(configuration.stories).to match_array(%w(12345 DE9876))
    end
  end

  after :each do
    configuration.reset
  end
end
