require "bindata"

module Net
  module TNS
    class Header < BinData::Record
      LENGTH = 8

      uint16be :packet_length
      uint16be :packet_checksum
      uint8    :packet_type
      uint8    :flags
      uint16be :checksum
    end

    class Packet < BinData::Record
      SESSION_DATA_UNIT_SIZE = 8192
      MAX_PAYLOAD_SIZE = SESSION_DATA_UNIT_SIZE - Header::LENGTH

      # BinData fields
      header :header


      def self.register_tns_type(tns_type)
        @@tns_packet_classes ||= {}
        @@tns_packet_types ||= {}
        if @@tns_packet_classes.has_key?(tns_type)
          existing_class = @@tns_packet_classes[tns_type]
          raise ArgumentError.new("Duplicate TNS Types Defined: #{existing_class} and #{self} both have a type of #{tns_type}")
        end

        @@tns_packet_classes[tns_type] = self
        @@tns_packet_types[self] = tns_type
        return nil
      end

      def self.from_socket( socket )
        Net::TNS.logger.debug("Attempting to read header")
        # TODO: allow sockets to implement their own timeout behavior
        require "timeout"
        begin
          header_raw = Timeout::timeout(5) do
            socket.read(Header::LENGTH)
          end
        rescue Timeout::Error
          raise Exceptions::ReceiveTimeoutExceeded
        end

        if header_raw.nil? || header_raw.length != Header::LENGTH
          header_length = header_raw.length unless header_raw.nil?
          raise Exceptions::ProtocolException.new("Failed to read complete header. Read #{header_length.to_i} bytes.")
        end

        header = Header.new()
        header.read( header_raw )
        Net::TNS.logger.debug("Read header. Reported packet length is #{header.packet_length} bytes")
        if header.packet_length > SESSION_DATA_UNIT_SIZE
          raise Exceptions::ProtocolException.new("Packet length in header (#{header.packet_length}) is longer than SDU size.")
        end

        payload_raw = socket.read( header.packet_length - Header::LENGTH )
        packet_raw = header_raw + payload_raw

        unless payload_class = @@tns_packet_classes[ header.packet_type ]
          raise Net::TNS::Exceptions::TNSException.new( "Unknown TNS packet type: #{header.packet_type}" )
        end

        unless packet_raw.length == header.packet_length
          raise Net::TNS::Exceptions::ProtocolException.new("Failed to read entire packet (read #{packet_raw.length} of #{header.packet_length} bytes).")
        end

        new_packet = payload_class.read( packet_raw )
        return new_packet
      end

      def update_header()
        self.header.packet_type = @@tns_packet_types[self.class]
        self.header.packet_length = self.num_bytes
      end

      def to_binary_s()
        update_header()
        return super
      end
    end
  end
end

require "pathname"
Dir.glob("#{Pathname.new(__FILE__).dirname}/packets/*.rb") { |file| require file }
