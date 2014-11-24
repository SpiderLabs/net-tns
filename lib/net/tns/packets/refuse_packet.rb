module Net
  module TNS
    class RefusePacket < Packet
      register_tns_type 4

      uint8     :user_reason
      uint8     :system_reason
      uint16be  :data_length
      string    :data, :read_length => :data_length
    end
  end
end
