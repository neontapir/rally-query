require 'logger'
require_relative 'options_provider'

module LoggingProvider
  def log(log_location = nil)
    unless $log
      log_location = log_location || STDERR
      $log = Logger.new log_location

      options_provider = OptionsProvider.new
      $log.level = options_provider.options.debug? ? Logger::DEBUG : Logger::INFO
      $log.debug "Logger started, will log #{$log.level} and below"
    end
    $log
  end
end
