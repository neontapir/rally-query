# COVERAGE=yes rspec .simplecov spec/*_spec.rb

if ENV["COVERAGE"] == 'yes'
  require 'SimpleCov'
  SimpleCov.start
end
