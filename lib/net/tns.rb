module Net
  module TNS
    require "net/tns/packet"
    require "net/tns/exceptions"
    require "net/tns/client"
    require "net/tns/connection"
    require "net/tns/gem_version"
    require "net/tns/helpers/string_helpers"

    def self.logger
      unless defined?(@@logger)
        require "logger"
        @@logger = Logger.new(STDERR)
        @@logger.progname = "Net::TNS"
        @@logger.sev_threshold = 6 unless $DEBUG
      end
      return @@logger
    end
  end
end
