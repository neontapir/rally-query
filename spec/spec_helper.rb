if ENV['COVERAGE'] == 'yes'
  begin
    require 'simplecov'
    SimpleCov.start do
      add_filter '/spec/'
    end
  rescue LoadError => e
    puts "Could not load SimpleCov, continuing without code coverage (reason: #{e})"
  end
end

require 'rspec'
require 'vcr'
require_relative 'vcr_setup'

RSpec.configure do |config|
  # declare an exclusion filter
  config.filter_run_excluding broken: true
  # force expect syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# figure out where we are being loaded from
if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    raise 'foo'
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:

    require 'spec/spec_helper'

  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.

  Loaded this time from:

    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end