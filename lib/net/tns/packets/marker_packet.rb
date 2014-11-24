module Net
  module TNS
    class MarkerPacket < Packet
      register_tns_type 12

      uint8    :marker_type
      rest     :data

      def self.create_request
        request = self.new
        request.marker_type = 1
        request.data = "0002".tns_unhexify

        return request
      end
    end
  end
end
