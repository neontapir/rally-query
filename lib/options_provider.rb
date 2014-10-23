require 'logger'
require 'slop'
require_relative 'secrets_store'

class OptionsProvider
  attr_accessor :options

  def initialize
    @options = Slop.parse(:help => true) do
      on :analysis, 'Export to CSV for Frank Vega\'s analysis script'
      # noinspection RubyQuotedStringsInspection
      on :b, :basic, 'Export basic data to CSV'
      on "c=", :credentials, 'Write credentials for system to secret store'
      on :d, :debug, 'Print debug messages'
      on :f, :feature, 'Display list of features'
      on :header, 'Print header with export types'
      # noinspection RubyQuotedStringsInspection
      on "i=", :input, 'File to read story IDs from'
      on 'workspace=', 'Write workspace ID for system to secret store'
      on :p, :project, 'Arguments are project names to query for stories'
      on :r, :release, 'Arguments are release names to query for stories'
      on :screen, 'Display to screen'
      # noinspection RubyQuotedStringsInspection
      on "s=", :system, 'System to query: Rally or Jira'
      on :x, :export, 'Export to CSV'
    end
  end
end
