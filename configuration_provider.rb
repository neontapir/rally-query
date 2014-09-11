require 'logger'
require 'slop'
require_relative('credentials_provider')

module ConfigurationProvider
  def configuration
    $configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :options, :credentials, :rally_workspace, :stories

    def initialize
      @options = Slop.parse! do
        on "c=", :credentials, 'Write credentials'
        on :d, :debug, 'Print debug messages'
        on :h, :header, 'Print header with export'
        # noinspection RubyQuotedStringsInspection
        on "i=", :input, 'File to read story IDs from'
        on :s, :screen, 'Display to screen'
        on :x, :export, 'Export to CSV'
      end

      credentialsProvider = CredentialsProvider.new
      unless @options[:credentials].nil?
        new_creds = @options[:credentials]
        puts "Creating credentials file at #{credentialsProvider.filename}"
        credentialsProvider.set new_creds
        exit
      end

      @stories = ARGV
      @credentials = credentialsProvider.get
      if (@credentials == '')
        fail "Rally credentials file missing (#{credentialsProvider.filename}). Run this script with '-c username:password' to set."
      end

      #if @options.key? :input
      unless @options[:input].nil?
        read_file @options[:input]
      end

      @rally_workspace = 208_717_725
    end

    def formatter
      case
        when @options.export?
          'WorkItemExportFormat'
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
