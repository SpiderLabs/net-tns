module Net
  module TNS
    class RedirectPacket < Packet
      register_tns_type 5

      uint16be :data_length
      string   :data, :read_length => :data_length
    end
  end
end
