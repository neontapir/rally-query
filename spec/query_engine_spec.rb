require 'logger'
require_relative 'spec_helper'
require_relative '../lib/configuration_factory'
require_relative '../query_engine'
require_relative 'capture'

describe QueryEngine do
  it 'is not nil' do
    expect(subject).not_to be_nil
  end

  it 'displays data' do
    ConfigurationFactory.ensure
    configatron.temp do
      configatron.stories = []
      c = Capture.capture do
        subject.execute
      end
      expect(c.stdout).not_to be_nil
    end
  end
end