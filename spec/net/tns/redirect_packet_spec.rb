require "net/tns/packet_spec_helper"

module Net
  module TNS
    describe RedirectPacket do
      let(:tns_type) {5}
      let(:field_values) {{
          :data_length =>53,
          :data =>"(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.0.4)(PORT=2143))"
      }}
      let(:raw_packet) {TnsSpecHelper.read_message('redirect.raw')}

      it_should_behave_like "a TNS packet class"
      it_should_behave_like "a TNS packet that can be properly received and parsed"
    end
  end
end
