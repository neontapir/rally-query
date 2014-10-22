require 'logger'
require 'slop'
require_relative 'secrets_store'

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
      # puts "DEBUG: Command line options: #{@options}"

      unless @options[:project].nil? || @options[:release].nil?
        raise 'Project and release cannot both be selected'
      end

      establish_secret_store_data

      #if @options.key? :input
      unless @options[:input].nil?
        read_file @options[:input]
      end

      if @options[:release].nil? && @options[:project].nil?
        @stories = ARGV
      else
        unless @options[:release].nil?
          if @options.feature?
            @stories = populate_features_from_releases
          else
            @stories = populate_stories_from_releases
          end
        end

        unless @options[:project].nil?
          if @options.feature?
            @stories = populate_features_from_projects
          else
            @stories = populate_stories_from_projects
          end
        end
      end
    end

    def establish_secret_store_data
      system = @options[:system] || 'Rally'
      store_location = File.expand_path('../your_credentials.yml', File.dirname(__FILE__))
      secrets_store = SecretsStore.new store_location, system

      unless @options[:credentials].nil?
        new_creds = @options[:credentials]
        puts "Creating credentials for #{system} at #{secrets_store.filename}"
        secrets_store.set_password new_creds
        exit
      end

      unless @options[:workspace].nil?
        new_workspace = @options[:workspace]
        puts "Adding workspace for #{system} at #{secrets_store.filename}"
        secrets_store.set 'workspace', new_workspace
        exit
      end

      @credentials = secrets_store.get_password
      if @credentials.empty?
        raise "#{system} credentials file missing (#{secrets_store.filename}). Run this script with '-c username:password' to set."
      end

      if system == 'Rally'
        @rally_workspace = secrets_store.get 'workspace'
        if @rally_workspace.empty?
          raise "#{system} workspace value missing (#{secrets_store.filename}). Run this script with '--workspace ID' to set."
        end
      end
    end

    def formatter
      case
        when @options.export?
          'WorkItemExportFormat'
        when @options.analysis?
          'WorkItemAnalysisFormat'
        when @options.feature?
          'WorkItemFeatureFormat'
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

    def populate_stories_from_releases
      require_relative 'release_detailer'
      detailer = ReleaseDetailer.new

      stories = []
      ARGV.each do |release|
        stories += detailer.get_work_items release
      end
      stories
    end

    def populate_features_from_releases
      require_relative 'release_detailer'
      detailer = ReleaseDetailer.new

      features = []
      ARGV.each do |release|
        features += detailer.get_portfolio_items release
      end
      features
    end

    def populate_stories_from_projects
      require_relative 'project_detailer'
      detailer = ProjectDetailer.new

      stories = []
      ARGV.each do |project|
        stories += detailer.get_work_items project
      end
      stories
    end

    def populate_features_from_projects
      require_relative 'project_detailer'
      detailer = ProjectDetailer.new

      features = []
      ARGV.each do |project|
        features += detailer.get_portfolio_items project
      end
      features
    end
  end
end
