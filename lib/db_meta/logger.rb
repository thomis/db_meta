require "logger"

class Logger
  class Formatter
    FORMAT2 = "%s\t%s\t%s\n"

    def call(severity, time, progname, msg)
      time_in_string = "#{time.strftime("%Y-%m-%d %H:%M:%S")}.#{"%03d" % (time.usec / 1000)}"
      FORMAT2 % [time_in_string, severity, msg]
    end
  end
end
