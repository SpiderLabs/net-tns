require "net/tns"
require "net/tti/message"

module Net
  module TTI
    class ConnectionParameters
      attr_accessor :platform
      attr_accessor :architecture
      attr_accessor :proSvrVer
      attr_accessor :proSvrStr
      attr_accessor :tns_version
      attr_accessor :svrCharSet
      attr_accessor :svrFlags
      attr_accessor :svrCompiletimeCapabilities
      attr_accessor :svrRuntimeCapabilities

      def to_s
        return "Platform: #{@platform||nil}" +
          "; Architecture: #{@architecture||nil}" +
          "; TNS Version: #{@tns_version||nil}" +
          "; Pro server version: #{@proSvrVer||nil}" +
          "; Pro server string: #{@proSvrStr||nil}" +
          "; Server character set: #{@svrCharSet||nil}" +
          "; Server flags: #{@svrFlags||nil}" + 
          "; Server Compiletime Capabilities: #{@svrCompiletimeCapabilities.unpack('C'*@svrCompiletimeCapabilities.length).collect {|x| x.to_s 16}||nil}" +
          "; Server Runtime Capabilities: #{@svrRuntimeCapabilities.unpack('C'*@svrRuntimeCapabilities.length).collect {|x| x.to_s 16}||nil}"
      end
    end

    class Connection
      attr_reader :conn_params

      def initialize(opts={})
        Net::TTI.logger.debug("Creating new TNS Connection")
        @tns_connection = Net::TNS::Connection.new(opts)
        @conn_params = ConnectionParameters.new()
      end

      def connect(opts={})
        Net::TTI.logger.debug("Connection#connect called")
        @tns_connection.connect(opts)
        @conn_params.tns_version = @tns_connection.tns_protocol_version

        Net::TTI.logger.debug("Sending protocol negotiation request")
        proto_nego_request = ProtocolNegotiationRequest.create_request()
        proto_nego_response_raw = send_and_receive( proto_nego_request )

        proto_nego_response = ProtocolNegotiationResponse.read( proto_nego_response_raw )
        proto_nego_response.populate_connection_parameters( @conn_params )

        Net::TTI.logger.debug("Sending data type negotiation request")
        dt_nego_request = DataTypeNegotiationRequest.create_request( @conn_params )
        dt_nego_response_raw = send_and_receive( dt_nego_request )

        return nil
      end

      def disconnect()
        @tns_connection.disconnect
      end

      def send_and_receive( tti_message )
        send_tti_message(tti_message)
        receive_tti_message()
      end

      # Sends a TTI message. This function takes a TTI payload, embeds it in one
      # or more TNS Data packets and sends those packets.
      def send_tti_message( tti_message )
        raw_message = tti_message.to_binary_s
        Net::TTI.logger.debug( "Connection#send_tti_message called with #{raw_message.length}-byte #{tti_message.class} message" )

        # Split the message into multiple packets if necessary
        max_data = @tns_connection.tns_sdu - 12 # 12 = 10 (HEADER) + 2 (FLAGS)
        raw_message.scan(/.{1,#{max_data}}/m).each do |raw_message_part|
          tns_packet = Net::TNS::DataPacket.new()
          tns_packet.data = raw_message_part
          Net::TTI.logger.debug( "Sending data packet (#{tns_packet.num_bytes} bytes total)" )
          @tns_connection.send_tns_packet( tns_packet )
        end
      end

      def receive_tti_message( waiting_for_error_message = false, max_message_length=10_000 )
        # This is structured as a loop in order to handle messages (e.g. Markers)
        # that need to be handled without returning to the caller. To keep a malicious
        # server from making us loop continuously, we set an arbitrary limit of
        # 10 loops without a "real" message before we throw an exception.
        receive_count = 0
        while ( true )
          receive_count += 1
          if ( receive_count >= 3 )
            raise Exceptions::ProtocolException.new( "Maximum receive attempts exceeded - too many Markers received." )
          end

          Net::TTI.logger.debug("Attempting to receive packet (try ##{receive_count})")
          case tns_packet = @tns_connection.receive_tns_packet()
          when Net::TNS::DataPacket
            message_data = tns_packet.data
            # If this is a long packet, the data may have hit the max length and
            # carried into an additional packet. We wouldn't need to do this if
            # we could fully parse every message (or at least know lengths to
            # read). I'm looking at you, DataTypeNegotiationResponse.
            if tns_packet.num_bytes > 1900
              begin
                max_message_length -= message_data.length
                message_data += receive_tti_message(waiting_for_error_message, max_message_length)
              rescue Net::TNS::Exceptions::ReceiveTimeoutExceeded
                Net::TTI.logger.debug("Hit receive timeout trying to read another Data packet")
              end
            end

            return message_data

          # We received an error notification
          when Net::TNS::MarkerPacket
            Net::TTI.logger.info("Received MarkerPacket")
            # TNS Markers seem to come in pairs. If we've already got one and sent
            # the request for the error message, we'll ignore subsequent markers
            # until we get the error message.
            unless waiting_for_error_message
              error_message = get_error_message()
              raise Exceptions::ErrorMessageReceived.new( error_message )
            end

          # We received something else
          else
            Net::TTI.logger.warn("Received #{tns_packet.class} instead of Data")
            if waiting_for_error_message
              raise Exceptions::ProtocolException.new( "Invalid response while waiting for error message - got #{tns_packet.class}" )
            else
              raise Exceptions::ProtocolException.new( "Received #{tns_packet.class} instead of TNS data packet (for TTI)" )
            end
          end
        end
      end

      def get_error_message
        error_request = Net::TNS::MarkerPacket.create_request()
        @tns_connection.send_tns_packet( error_request )

        raw_response = receive_tti_message(true)
        response = Message.from_data_string(raw_response)
        
        unless response.is_a?(ErrorMessage)
          raise Exceptions::ProtocolException.new( "Received #{response.class} instead of error message" )
        end

        return response.message
      end
    end
  end
end
