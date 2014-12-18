require "net/tns/packet_spec_helper"

module Net
  module TNS
    describe ResendPacket do
      let(:tns_type) {11}
      let(:field_values) {Hash.new}
      let(:raw_packet) {TnsSpecHelper.read_message('resend.raw')}

      it_should_behave_like "a TNS packet class"
      it_should_behave_like "a TNS packet that can be properly received and parsed"
    end
  end
end
