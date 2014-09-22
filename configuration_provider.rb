require 'logger'
require 'slop'
require_relative 'credentials_provider'
#require_relative 'release_detailer'

module ConfigurationProvider
  def configuration
    $configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :options, :credentials, :rally_workspace, :stories

    def initialize
      @options = Slop.parse!(:help => true) do
        on :analysis, 'Export to CSV for Frank Vega\'s analysis script'
        # noinspection RubyQuotedStringsInspection
        on "c=", :credentials, 'Write credentials'
        on :d, :debug, 'Print debug messages'
        on :header, 'Print header with export types'
        # noinspection RubyQuotedStringsInspection
        on "i=", :input, 'File to read story IDs from'
        on :r, :release, 'Arguments are release names to query for stories'
        on :s, :screen, 'Display to screen'
        on :x, :export, 'Export to CSV'
      end
      # puts "DEBUG: Command line options: #{@options}"

      credentials_provider = CredentialsProvider.new
      unless @options[:credentials].nil?
        new_creds = @options[:credentials]
        puts "Creating credentials file at #{credentials_provider.filename}"
        credentials_provider.set new_creds
        exit
      end

      @credentials = credentials_provider.get
      if @credentials.empty?
        fail "Rally credentials file missing (#{credentials_provider.filename}). Run this script with '-c username:password' to set."
      end

      #if @options.key? :input
      unless @options[:input].nil?
        read_file @options[:input]
      end

      if @options[:release].nil?
        @stories = ARGV
      else
        require_relative 'release_detailer'
        detailer = ReleaseDetailer.new

        @stories = []
        ARGV.each do |release|
          @stories += detailer.get_work_items release
        end
      end

      @rally_workspace = 208_717_725
    end

    def formatter
      case
        when @options.export?
          'WorkItemExportFormat'
        when @options.analysis?
          'WorkItemAnalysisFormat'
        else
          'WorkItemScreenFormat'
      end
    end

    def log_level
      case
        when @options.debug?
          Logger::DEBUG
        else
          Logger::INFO
      end
    end

    private

    def read_file(filename)
      File.open(filename).each_line do |line|
        @stories << line.chomp
      end
    end
  end
end
