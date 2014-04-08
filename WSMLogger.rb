require 'date'

class WSMLogger
  @@shared_instance
  attr_accessor :log_format, :logging_options, :log_level

  def log_format
    @log_format ||= {
      time_stamp: true,
      time_options: {},
      full_path: false,
      method_name: true,
      line_numbers: true
    }
  end

  def logging_options
    @logging_options ||= {
      level: 0,            #       level:(int)level
      line: 0,             #        line:(int)line
      format: "",          #      format:(NSString *)format, ...

      #implement later
      asynchronous: false, # + (void)log:(BOOL)asynchronous
      flag: 0,             #        flag:(int)flag
      context: 0,          #     context:(int)context
      file: "",            #        file:(const char *)file
      function: "",        #    function:(const char *)function
      tag: 0               #         tag:(id)tag
    }
  end

  #class / Singleton methods

  def self.shared_instance
    @@shared_instance ||= WSMLogger.new
  end

  def self.p (log)
    puts WSMLogger.shared_instance.format_log_message(caller[0], log)
  end

  def self.log_format= (options)
    WSMLogger.shared_instance.log_format.merge!(options)
  end

  def self.verbose (log)
    if WSMLogger.shared_instance.log_level >= 3
      puts WSMLogger.shared_instance.format_log_message(caller[0], log, {level: 3}).cyan
    end
  end

  def self.info (log)
    if WSMLogger.shared_instance.log_level >= 2
      puts WSMLogger.shared_instance.format_log_message(caller[0], log, {level: 2}).blue
    end
  end

  def self.warn (log)
    if WSMLogger.shared_instance.log_level >= 1
      puts WSMLogger.shared_instance.format_log_message(caller[0], log, {level: 1}).cyan
    end
  end

  def self.error (log)
    if WSMLogger.shared_instance.log_level >= 0
      puts WSMLogger.shared_instance.format_log_message(caller[0], log, {level: 0}).red
    end
  end

  #instance methods

  def initialize

  end

  def log_level
    @log_level ||= 3
  end

  def w (log)
    puts format_log_message(caller[0], log)
  end

  def format_log_message(log_caller, log, options = {level: 3})

    time_stamp = time_for_caller(log_caller)

    thread_id = thread_for_caller(log_caller)

    source_file = source_file_from_caller(log_caller)

    method_name = method_name_from_caller(log_caller)

    line_numbers = line_number_from_caller(log_caller)

    #queue_style should look like:
    #MM:SS.mmm-thread[File|method:line] LOG_STATEMENT
    "#{time_stamp}-#{thread_id}[#{source_file}|#{method_name}:#{line_numbers}] #{log}"
  end

  def thread_for_caller(log_caller)
    (Thread.current.object_id % 10000).to_s
  end

  def time_for_caller(log_caller)
    d_time = DateTime.now
    d_time.strftime("%M:%S.%L")
  end

  def source_file_from_caller(log_caller, limit = [])
    long_path = log_caller.split(":").first
    self.log_format[:full_path] ? long_path : long_path.split("/").last
  end

  def method_name_from_caller(log_caller)
    self.log_format[:method_name] ? log_caller[/`(.*?)'/][1...-1] : ""
  end

  def line_number_from_caller(log_caller)
    self.log_format[:line_numbers] ? log_caller[/:[0-9]*:/][1...-1] : ""
  end

end

class String
  def black;          "\033[30m#{self}\033[0m" end
  def red;            "\033[31m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def brown;          "\033[33m#{self}\033[0m" end
  def blue;           "\033[34m#{self}\033[0m" end
  def magenta;        "\033[35m#{self}\033[0m" end
  def cyan;           "\033[36m#{self}\033[0m" end
  def gray;           "\033[37m#{self}\033[0m" end

  def bg_black;       "\033[40m#{self}\0330m"  end
  def bg_red;         "\033[41m#{self}\033[0m" end
  def bg_green;       "\033[42m#{self}\033[0m" end
  def bg_brown;       "\033[43m#{self}\033[0m" end
  def bg_blue;        "\033[44m#{self}\033[0m" end
  def bg_magenta;     "\033[45m#{self}\033[0m" end
  def bg_cyan;        "\033[46m#{self}\033[0m" end
  def bg_gray;        "\033[47m#{self}\033[0m" end

  def bold;           "\033[1m#{self}\033[22m" end

  def reverse_color;  "\033[7m#{self}\033[27m" end
end


# WSMLogger.logg_format = {log_style: :queue_format}
#
# def test
#   WSMLogger.verbose "What's going on here."
# end
#
# WSMLogger.error "What's going on here."
# test