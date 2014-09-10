require 'logger'

require_relative 'configuration_provider'

module LoggingProvider
  include ConfigurationProvider

  def log(log_location = nil)
    unless $log
      log_location = log_location || STDERR
      $log = Logger.new log_location
      $log.level = configuration.log_level || Logger::INFO
    end
    $log
  end
end
