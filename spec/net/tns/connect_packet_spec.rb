require "net/tns/packet_spec_helper"

module Net
  module TNS
    describe ConnectPacket do
      let(:tns_type) {1}
      let(:field_values) {{
        :maximum_version => 0x0134,
        :minimum_version => 0x012c,
        :sdu_size => 0x0800,
        :maximum_tdu_size => 0x7fff,
        :protocol_flags => 0x4f98,
        :byte_order => 1,
        :flags1 => 1,
        :flags2 => 1,
        :data => raw_packet[34,123]
      }}
      let(:raw_packet) {TnsSpecHelper.read_message('connect.raw')}

      it_should_behave_like "a TNS packet class"
      it_should_behave_like "a TNS packet that can be properly created and sent"
    end
  end
end
