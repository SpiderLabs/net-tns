require "net/tns/packet_spec_helper"

module Net
  module TNS
    describe RefusePacket do
      let(:tns_type) {4}
      let(:field_values) {{
          :user_reason => 0x22,
          :system_reason => 0x00,
          :data_length => 85,
          :data => "(DESCRIPTION=(ERR=12618)(VSNNUM=169869568)(ERROR_STACK=(ERROR=(CODE=12618)(EMFI=4))))"
      }}
      let(:raw_packet) {TnsSpecHelper.read_message('refuse.raw')}

      it_should_behave_like "a TNS packet class"
      it_should_behave_like "a TNS packet that can be properly received and parsed"
    end
  end
end
