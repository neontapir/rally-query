require 'configatron'
require 'logger'
require_relative 'secrets_store'
require_relative 'options_provider'
require_relative 'project_lookup'
require_relative 'release_lookup'

class ConfigurationFactory
  def self.reset
    configatron.reset!
    $configatron_initialized = false
    self.ensure
  end

  def self.ensure
    unless $configatron_initialized
      $configatron_initialized = true
      ConfigatronSetup.new
    end
    configatron
  end

  class ConfigatronSetup
    def initialize
      options_provider = OptionsProvider.new
      configatron.options = options_provider.options

      unless configatron.options[:project].nil? || configatron.options[:release].nil?
        raise 'Project and release cannot both be selected'
      end

      configatron.log_level = log_level
      logger
      establish_secret_store_data

      unless configatron.options[:input].nil?
        read_file configatron.options[:input]
      end

      configatron.formatter = formatter
      configatron.stories = stories
    end

    def logger
      log_location = log_location || STDERR
      log = Logger.new log_location
      log.level = configatron.log_level
      log.debug "Logger started, will log #{log.level} and below"

      configatron.log = log
    end

    def establish_secret_store_data
      configatron.system = configatron.options[:system] || 'Rally'
      store_location = File.expand_path('../your_credentials.yml', File.dirname(__FILE__))
      secrets_store = SecretsStore.new store_location, configatron.system

      unless configatron.options[:credentials].nil?
        new_creds = configatron.options[:credentials]
        puts "Creating credentials for #{configatron.system} at #{secrets_store.filename}"
        secrets_store.set_password new_creds
        exit
      end

      unless configatron.options[:workspace].nil?
        new_workspace = configatron.options[:workspace]
        puts "Adding workspace for #{configatron.system} at #{secrets_store.filename}"
        secrets_store.set 'workspace', new_workspace
        exit
      end

      credentials = secrets_store.get_password
      if credentials.empty?
        raise "#{configatron.system} credentials file missing (#{secrets_store.filename}). Run this script with '-c username:password' to set."
      end
      configatron.credentials = credentials

      if configatron.system == 'Rally'
        rally_workspace = secrets_store.get 'workspace'
        if rally_workspace.empty?
          raise "#{configatron.system} workspace value missing (#{secrets_store.filename}). Run this script with '--workspace ID' to set."
        end
        configatron.rally_workspace = rally_workspace
      end
    end

    def formatter
      case
        when configatron.options.export?
          'WorkItemExportFormat'
        when configatron.options.analysis?
          'WorkItemAnalysisFormat'
        when configatron.options.feature?
          'WorkItemFeatureFormat'
        when configatron.options.basic?
          'WorkItemBasicFormat'
        else
          'WorkItemScreenFormat'
      end
    end

    def log_level
      case
        when configatron.options.debug?
          Logger::DEBUG
        else
          Logger::INFO
      end
    end

    def stories
      unless @stories
        if configatron.options[:release].nil? && configatron.options[:project].nil?
          @stories = ARGV
        else
          unless configatron.options[:release].nil?
            if configatron.options.feature?
              @stories = populate_features_from_releases
            else
              @stories = populate_stories_from_releases
            end
          end

          unless configatron.options[:project].nil?
            if configatron.options.feature?
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

      lookup = ReleaseLookup.new

      stories = []
      ARGV.each do |release|
        stories += lookup.get_work_items release
      end
      stories
    end

    def populate_features_from_releases
      lookup = ReleaseLookup.new

      features = []
      ARGV.each do |release|
        features += lookup.get_portfolio_items release
      end
      features
    end

    def populate_stories_from_projects
      lookup = ProjectLookup.new

      stories = []
      ARGV.each do |project|
        stories += lookup.get_work_items project
      end
      stories
    end

    def populate_features_from_projects
      lookup = ProjectLookup.new

      features = []
      ARGV.each do |project|
        features += lookup.get_portfolio_items project
      end
      features
    end
  end
end