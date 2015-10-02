require "net/tns/version"

module Net
  module TNS
    class ConnectPacket < Packet
      register_tns_type 1

      uint16be  :maximum_version,   :initial_value => Net::TNS::Version::VERSION_11G
      uint16be  :minimum_version,   :initial_value => Net::TNS::Version::ALL_VERSIONS.min
      uint16be  :service_flags
      # session data unit size
      uint16be  :sdu_size,          :initial_value => Net::TNS::Packet::SESSION_DATA_UNIT_SIZE
      # maximum transmission data unit size
      uint16be  :maximum_tdu_size,  :initial_value => 0x7fff
      uint16be  :protocol_flags,    :initial_value => 0xc608
      # Described as "Max packets before ACK" by http://www.pythian.com/blog/repost-oracle-protocol/
      uint16be  :line_turnaround_value
      # 0x0001 for little endian 0x0100 for big endian
      uint16be  :byte_order,        :initial_value => 0x0001
      uint16be  :data_length,       :value => lambda { data.length } # Length of Connect Data
      uint16be  :data_offset,       :value => lambda { supports_trace? ? 58 : 34 }  # Offset to Connect Data (from start of TNS header)
      # Maximum Receivable Connect Data
      uint32be  :maximum_connect_receive
      uint8     :flags1,        :initial_value => 0x41
      uint8     :flags2,        :initial_value => 0x41

      uint32be  :trace_item1,         :onlyif => :supports_trace?
      uint32be  :trace_item2,         :onlyif => :supports_trace?
      uint64be  :trace_connection_id, :onlyif => :supports_trace?
      uint64be  :unknown,             :onlyif => :supports_trace?

      string    :data

      def self.make_connect_request(dst_host, dst_port, target_clause)
        conn_info = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=%s)(PORT=%i))(CONNECT_DATA=(SERVER=DEDICATED)%s))" %
                      [ dst_host, dst_port, target_clause ]
        return self.new(:data => conn_info)
      end

      def self.make_connection_by_sid(dst_host, dst_port, sid)
        target_clause = "(SID=#{sid})"
        return make_connect_request(dst_host, dst_port, target_clause)
      end

      def self.make_connection_by_service_name(dst_host, dst_port, service_name)
        target_clause = "(SERVICE_NAME=#{service_name})"
        return make_connect_request(dst_host, dst_port, target_clause)
      end

      def supports_trace?
        return maximum_version > 308
      end
    end
  end
end
