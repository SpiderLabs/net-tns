module Net::TNS
  module Exceptions
    class TNSException < StandardError
    end

    class ProtocolException < TNSException
    end


    class ReceiveTimeoutExceeded < TNSException
    end

    class ConnectionClosed < TNSException
    end

    class RefuseMessageReceived < TNSException
    end

    class RedirectMessageReceived < TNSException
      attr_reader :new_port
      attr_reader :new_host

      def initialize( message )
        super( message )

        host_matches = /\(HOST=([^\)]+)\)/.match( self.message )
        @new_host = host_matches[1] unless host_matches.nil?

        port_matches = /\(PORT=(\d{1,5})\)/.match( self.message )
        @new_port = port_matches[1] unless port_matches.nil?
      end
    end
  end
end
