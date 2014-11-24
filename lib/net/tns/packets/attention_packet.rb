module Net
  module TNS
    class AttentionPacket < Packet
      register_tns_type 13

      rest     :data
    end
  end
end
