require 'logger'

class MultiIO
  def initialize(*targets)
    @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end
end

def momentum_api_logger
  log_file = File.open("log/scan.log", "a")
  logger = Logger.new MultiIO.new(STDOUT, log_file)
  logger.datetime_format = "%y-%m-%d %H:%M:%S"
  logger
end
