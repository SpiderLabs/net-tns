require "net/tns/packet_spec_helper"

module Net
  module TNS
    describe AbortPacket do
      let(:tns_type) {9}
      let(:field_values) {{
        :user_reason => 0,
        :system_reason => 0,
        :data => "",
      }}
      let(:raw_packet) {nil}

      it_should_behave_like "a TNS packet class"
      it_should_behave_like "a TNS packet that can be properly received and parsed"
    end
  end
end
