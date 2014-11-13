require 'configatron'
require 'logger'
require_relative 'secrets_store'
require_relative 'options_provider'

class ConfigurationFactory
  def self.create
    setup = ConfigatronSetup.new
    # configatron.formatter = setup.formatter
    # configatron.stories = setup.stories
    # configatron.log_level = setup.log_level
  end

  class ConfigatronSetup
    def initialize
      options_provider = OptionsProvider.new
      configatron.options = options_provider.options

      unless configatron.options[:project].nil? || configatron.options[:release].nil?
        raise 'Project and release cannot both be selected'
      end

      establish_secret_store_data

      unless configatron.options[:input].nil?
        read_file configatron.options[:input]
      end

      configatron.formatter = formatter
      configatron.stories = stories
      configatron.log_level = log_level
    end

    def establish_secret_store_data
      configatron.system = configatron.options[:system] || 'Rally'
      store_location = File.expand_path('../your_credentials.yml', File.dirname(__FILE__))
      secrets_store = SecretsStore.new store_location, configatron.system

      unless configatron.options[configatron.credentials].nil?
        new_creds = configatron.options[configatron.credentials]
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