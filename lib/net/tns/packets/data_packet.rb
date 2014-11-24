module Net
  module TNS
    class DataPacket < Packet
      register_tns_type 6

      uint16be :flags
      rest     :data

      def self.max_data_length
        return Net::TNS::Packet::MAX_PAYLOAD_SIZE - 2   # 2 = flags.length
      end

      def self.make_disconnect_request
        packet = self.new()
        packet.flags = 0x0040
        return packet
      end
    end
  end
end
