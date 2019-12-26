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


def momentum_api_logger(log_file_locaiton)
  # log_file = File.open('_run.log', 'a')   # saves in random places
  log_file = File.open(log_file_locaiton, 'a')
  logger = Logger.new MultiIO.new(log_file, STDOUT)
  logger.datetime_format = "%y-%m-%d %H:%M:%S"
  logger
end


def scan_pass
  @discourse.counters[:'Processed Users'], @discourse.counters[:'Skipped Users'] = 0, 0
  @discourse.apply_to_users
  @scan_passes += 1

  wait = @discourse.options[:minutes_between_scans] || 5
  @discourse.options[:logger].info "Pass #{@scan_passes} complete for #{@discourse.counters[:'Processed Users']} users, #{@discourse.counters[:'Skipped Users']} skipped. Waiting #{wait} minutes ..."
  @discourse.options[:logger].close
  @discourse.options[:logger] = momentum_api_logger(@discourse.options[:log_file])
  sleep wait * 60
end


def scan_hourly

  begin
    scan_pass

  rescue Exception => exception       # Recovers from any crash since Jul 22, 2019?
    @discourse.options[:logger].warn "Scan Level Exception Rescue type #{exception.class}, #{exception.message}: Sleeping for 90 minutes ...."
    sleep 90 * 60
    scan_hourly
  end

  if @scan_passes < @scan_passes_end or @scan_passes_end < 0
    scan_hourly
    @discourse.options[:logger].info "... Exiting ..."
  end

end
