require 'configatron'
require 'logger'
require_relative 'secrets_store'
require_relative 'options_provider'

class ConfigurationFactory
  def self.create
    config = ConfigurationObject.new

    configatron.options = config.options
    configatron.credentials = config.credentials
    configatron.system = config.system
    configatron.rally_workspace = config.rally_workspace
    configatron.formatter = config.formatter
    configatron.stories = config.stories
    configatron.log_level = config.log_level

    configatron
  end

  class ConfigurationObject
    attr_accessor :options, :credentials, :rally_workspace, :system

    def initialize
      options_provider = OptionsProvider.new
      @options = options_provider.options

      unless @options[:project].nil? || @options[:release].nil?
        raise 'Project and release cannot both be selected'
      end

      establish_secret_store_data

      #if @options.key? :input
      unless @options[:input].nil?
        read_file @options[:input]
      end
    end

    def establish_secret_store_data
      @system = @options[:system] || 'Rally'
      store_location = File.expand_path('../your_credentials.yml', File.dirname(__FILE__))
      secrets_store = SecretsStore.new store_location, @system

      unless @options[configatron.credentials].nil?
        new_creds = @options[configatron.credentials]
        puts "Creating credentials for #{@system} at #{secrets_store.filename}"
        secrets_store.set_password new_creds
        exit
      end

      unless @options[:workspace].nil?
        new_workspace = @options[:workspace]
        puts "Adding workspace for #{@system} at #{secrets_store.filename}"
        secrets_store.set 'workspace', new_workspace
        exit
      end

      @credentials = secrets_store.get_password
      if @credentials.empty?
        raise "#{@system} credentials file missing (#{secrets_store.filename}). Run this script with '-c username:password' to set."
      end

      if @system == 'Rally'
        @rally_workspace = secrets_store.get 'workspace'
        if @rally_workspace.empty?
          raise "#{@system} workspace value missing (#{secrets_store.filename}). Run this script with '--workspace ID' to set."
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
        when @options.basic?
          'WorkItemBasicFormat'
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

    def stories
      unless @stories
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
      @stories
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