module Net
  module TNS
    class AcceptPacket < Packet
      register_tns_type 2

      uint16be  :version
      uint16be  :service_flags
      uint16be  :sdu_size         # session data unit size
      uint16be  :maximum_tdu_size # maximum transmission data unit size
      uint16be  :byte_order       # 0x0001 for little endian 0x0100 for big endian
      uint16be  :data_length
      uint16be  :data_offset      # Offset to Connect Data (from parent header start)
      uint8     :flags1
      uint8     :flags2
      string    :padding, :read_length => lambda {data_offset - 24}
      string    :data,    :read_length => :data_length
    end
  end
end
