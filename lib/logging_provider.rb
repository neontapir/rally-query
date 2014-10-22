require 'logger'
require 'slop'

module LoggingProvider
  def log(log_location = nil)
    unless $log
      log_location = log_location || STDERR
      $log = Logger.new log_location

      options = Slop.parse do
        on :d, :debug
      end
      $log.level = options.debug? ? Logger::DEBUG : Logger::INFO
    end
    $log
  end
end
