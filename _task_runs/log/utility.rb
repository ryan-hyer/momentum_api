require 'logger'

class MultiIO
  def initialize(*targets)
    @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each do |t|
      if t.is_a?(File)
        t.send(:close)
      end
    end
  end
end


def momentum_api_logger
  log_file = File.open("log/scan.log", "a")
  logger = Logger.new MultiIO.new(log_file, STDOUT)
  logger.datetime_format = "%y-%m-%d %H:%M:%S"
  logger
end
