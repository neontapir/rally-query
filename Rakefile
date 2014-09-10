require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--order rand'
end

task default: :spec

task :coverage do
  # add simplecov
  ENV['COVERAGE'] = 'yes'
  # run the specs
  Rake::Task['spec'].execute
end
