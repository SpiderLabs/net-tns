module Net
  module TNS
    class Client
      def self.ping?(opts={})
        begin
          conn = Connection.new(opts)
          conn.open_socket()
          request = ConnectPacket.new(:data => "(CONNECT_DATA=(COMMAND=ping))")
          conn.send_and_receive( request )
          return true
        rescue Exceptions::ConnectionClosed
          return false
        rescue Exceptions::TNSException
          return true
        ensure
          conn.close_socket() unless conn.nil?
        end
      end

      def self.get_version(opts={})
        begin
          conn = Connection.new(opts)
          conn.open_socket()
          request = ConnectPacket.new(:data => "(CONNECT_DATA=(COMMAND=VERSION))")

          response = conn.send_and_receive( request )
          raise Exceptions::ProtocolException.new("Expected AcceptPacket in response (got #{response.class})") unless response.is_a?(AcceptPacket)

          version_data = response.data
        rescue Exceptions::RefuseMessageReceived => refuse_err
          version_data = refuse_err.message
        ensure
          conn.close_socket() unless conn.nil?
        end

        return nil if version_data.nil?

        if ( version_match = version_data.match( /Version ((?:\d+.)+\d+)/ ) ) then
          return version_match[1]
        # If that didn't work, see if we got an encoded version number
        elsif ( version_match = version_data.match( /\(VSNNUM=(\d+)\)/ ) ) then
          return parse_vsnnum(version_match[1])
        end
      end

      def self.get_status(opts={})
        begin
          conn = Connection.new(opts)
          conn.open_socket()
          request = ConnectPacket.new(:data => "(CONNECT_DATA=(COMMAND=STATUS)(VERSION=186647552))")

          status_response_raw = ""
          begin
            response = conn.send_and_receive( request )
          rescue EOFError
            # The first packet sent is an Accept with an unknown structure.
            # Attempting to parse it as an Accept results in an EOFError, due to
            # a data length that is greater than the available data.
          end

          response = conn.send_and_receive(ResendPacket.new())
          status_response_raw += response.data
          # Successful responses are typically spread across multiple Data packets.
          while ( response = conn.receive_tns_packet() )
            break unless response.is_a?(DataPacket)
            break if response.flags == 0x0040
            status_response_raw += response.data
          end
          return status_response_raw
        ensure
          conn.close_socket() unless conn.nil?
        end
      end

      # Parse the "VSNNUM" component of certain TNS listener responses, which
      # contains an encoded form of the version number.
      def self.parse_vsnnum(vsnnum_string)
        # The VSNNUM is a really insane way of encoding the version number. It
        # is a decimal number (e.g. 169869568) that, in hex (e.g. A200100),
        # is a weird representation of the dotted version
        # (e.g. 169869568 -> A200100 -> A.2.0.01.00 -> A.2.0.1.0 -> 10.2.0.1.0).
        raise ArgumentError unless vsnnum_string.is_a?(String)
        vsnnum_decimal = vsnnum_string.to_i

        version_components = []
        version_components << (( vsnnum_decimal >> 24 ) & 0xFF)
        version_components << (( vsnnum_decimal >> 20 ) & 0xF)
        version_components << (( vsnnum_decimal >> 16 ) & 0xF)
        version_components << (( vsnnum_decimal >>  8 ) & 0xFF)
        version_components << (( vsnnum_decimal >>  0 ) & 0xFF)

        return version_components.join('.')
      end
    end
  end
end
