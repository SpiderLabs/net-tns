require "net/tns/helpers/string_helpers"

module Net
  module TTI
    require "pathname"
    Dir.glob("#{Pathname.new(__FILE__).dirname}/tti/*.rb") { |file| require file }

    def self.logger
      unless defined?(@@logger)
        require "logger"
        @@logger = Logger.new(STDERR)
        @@logger.progname = "Net::TTI"
        @@logger.sev_threshold = 6 unless $DEBUG
      end
      return @@logger
    end
  end
end
