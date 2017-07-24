require "net/tns/packet"
require "net/tns/exceptions"

module Net
  module TNS
    class Connection
      attr_reader :tns_protocol_version
      attr_reader :tns_sdu

      def initialize(opts={})
        @socket = nil

        @host = opts.delete(:host)
        @port = opts.delete(:port) || 1521
        @new_socket_proc = opts.delete(:new_socket_proc)

        raise ArgumentError.new("Unrecognized options: #{opts.keys}") unless opts.empty?

        if @host.nil? == @new_socket_proc.nil?
          raise ArgumentError.new("Invalid socket options. Need :host and :port, OR :new_socket_proc")
        end
      end

      # This is a low-level function to directly open a socket for this connection.
      # Most callers should use #connect instead, which will open a socket and
      # negotiate a TNS connection.
      def open_socket
        Net::TNS.logger.debug("Connection#open_socket called")
        close_socket()

        if @host
          require "socket"
          Net::TNS.logger.info("Creating new TCPSocket for #{@host}:#{@port}")
          @socket = TCPSocket.new(@host, @port)
        elsif @new_socket_proc
          Net::TNS.logger.info("Calling new-socket proc for new socket")
          @socket = @new_socket_proc.call()
        else
          raise ArgumentError.new("Invalid socket options")
        end

        return
      end

      # This is a low-level function to directly close the socket for this connection.
      # Most callers should use #disconnect instead, which will disconnect the
      # TNS connection before closing the socket.
      def close_socket
        Net::TNS.logger.debug("Connection#close_socket called")
        begin
          unless @socket.nil? or @socket.closed?
            Net::TNS.logger.info("Closing socket")
            @socket.close
          end
        ensure
          @socket = nil
        end
      end

      def connect(opts={})
        sid = opts.delete(:sid) if opts.has_key?(:sid)
        service_name = opts.delete(:service_name) if opts.has_key?(:service_name)
        raise ArgumentError.new("Unrecognized opts: #{opts.keys}") unless opts.empty?
        raise ArgumentError.new("Must specify :sid or :service_name") unless sid.nil? != service_name.nil?

        open_socket() if @socket.nil?
        dst_host = @socket.peeraddr[3]
        dst_port = @socket.peeraddr[1]

        if sid
          Net::TNS.logger.debug("Connecting to target by SID (""#{sid}"")")
          connect_packet = ConnectPacket.make_connection_by_sid( dst_host, dst_port, sid )
        elsif service_name
          Net::TNS.logger.debug("Connecting to target by service name (""#{service_name}"")")
          connect_packet = ConnectPacket.make_connection_by_service_name( dst_host, dst_port, service_name )
        end

        response = send_and_receive(connect_packet)
        unless response.is_a?(AcceptPacket) || response.is_a?(RedirectPacket)
          raise Exceptions::ProtocolException.new("Unexpected response to Connect packet: #{response.class}")
        end
        if response.is_a?(RedirectPacket)
          # CLR extproc on 12c will end up here
          return
        end
        @tns_protocol_version = response.version.to_i
        @tns_sdu = response.sdu_size.to_i
        negotiate_ano()
      end

      def disconnect
        begin
          packet = DataPacket.make_disconnect_request
          send_tns_packet( packet )
        ensure
          close_socket()
        end
      end

      # Perform negotiation of Additional Network Options ("SNS" in Wireshark).
      # This is actually a different layer from TNS, but we're basically
      # ignoring it anyway, so there's no sense factoring it out of Net::TNS (yet).
      def negotiate_ano
        # create request for no ANO
        request = DataPacket.new()
        request.data = ("deadbeef00920a2001000004000004000300000000000400050a200100000800" +
                        "0100000b58884d7db000120001deadbeef000300000004000400010001000200" +
                        "01000300000000000400050a20010000020003e0e100020006fcff0002000200" +
                        "000000000400050a200100000c0001001106100c0f0a0b080201030003000200" +
                        "000000000400050a20010000030001000301").tns_unhexify

        Net::TNS.logger.debug("Sending ANO negotiation request")
        response = send_and_receive(request)
        unless response.is_a?(DataPacket) && response.data.start_with?("deadbeef".tns_unhexify)
          raise Exceptions::ProtocolException.new("Unexpected response to ANO request")
        end
        return response.data
      end
      private :negotiate_ano



      def send_and_receive( packet )
        send_tns_packet( packet )
        receive_tns_packet()
      end

      # @param packet [Net::TNS::Packet]
      def send_tns_packet( packet )
        if @socket.nil? || @socket.closed?
          Net::TNS.logger.warn( "Can't send packet to a closed or nil socket!" )
          return
        end
        # Store this in case we get a Resend
        @tns_last_sent_packet = packet
        Net::TNS.logger.debug( "Sending packet #{packet.class} (#{packet.num_bytes} bytes)" )
        @socket.write( packet.to_binary_s )
      end

      def resend_last_tns_packet
        if @tns_last_sent_packet.nil?
          raise Exceptions::TNSException.new( "Resend received without a packet to resend" )
        end
        send_tns_packet( @tns_last_sent_packet )
      end
      private :resend_last_tns_packet

      # Attempts to receive a TNS message.
      #
      # @param [Boolean] (Optional) Indicates a special state in which an error
      #   notification has been received, and we expect to be receiving a response
      #   to a request for the error message.
      # @return [Net::TNS::Packet]
      # @raise [Net::TNS::Exceptions::RefuseMessageReceived] If the other side
      #   sent TNS refuse message.
      # @raise [Net::TNS::Exceptions::TNSException] If another unexpected
      #   state or action occurs.
      def receive_tns_packet( waiting_for_error_message = false )
        # This is structured as a loop in order to handle messages (e.g. Resends)
        # that need to be handled without returning to the caller. To keep a malicious
        # server from making us loop continuously, we set an arbitrary limit of
        # 10 loops without a "real" message before we throw an exception.
        receive_count = 0
        while ( true )
          raise Exceptions::ConnectionClosed if @socket.closed?

          receive_count += 1
          if ( receive_count >= 3 )
            raise Exceptions::TNSException.new( "Maximum receive attempts exceeded - too many Resends received." )
          end

          # Try to receive a TNS packet
          Net::TNS.logger.debug("Attempting to receive packet (try ##{receive_count})")
          packet = Net::TNS::Packet.from_socket(@socket)

          case packet
          when Net::TNS::RefusePacket
            Net::TNS.logger.warn("Received RefusePacket")
            raise Exceptions::RefuseMessageReceived.new( packet.data )

          # # We received a redirect request (typical of Oracle 9 and possibly previous versions)
          # when Net::TNS::RedirectPacket
          #   raise Exceptions::RedirectMessageReceived.new( packet.data )

          # We received a request to resend the last packet
          when Net::TNS::ResendPacket
            Net::TNS.logger.debug("Received ResendPacket")
            # Re-send the last packet and then loop again
            resend_last_tns_packet()

          # We received a normal response
          else
            Net::TNS.logger.debug("Received #{packet.class} (#{packet.num_bytes} bytes)")
            return packet
          end
        end
      end
    end
  end
end
