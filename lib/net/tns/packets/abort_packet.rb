module Net
  module TNS
    class AbortPacket < Packet
      register_tns_type 9

      uint8   :user_reason
      uint8   :system_reason
      # not sure if this is correct, it's just what wireshark seems to do
      rest    :data
    end
  end
end
