require "net/tns/packet_spec_helper"

module Net
  module TNS
    describe DataPacket do
      let(:tns_type) {6}

      context "with packets from the server" do
        context "with a protocol negotiation response" do
          let(:field_values) {{
            :flags => 0x0000,
            :data => raw_packet[10..-1]
          }}
          let(:raw_packet) {TnsSpecHelper.read_message('data_proto_nego_response.raw')}

          it_should_behave_like "a TNS packet class"
          it_should_behave_like "a TNS packet that can be properly received and parsed"
        end

        context "with a query response" do
          let(:field_values) {{
            :flags => 0x0000,
            :data => raw_packet[10..-1]
          }}
          let(:raw_packet) {TnsSpecHelper.read_message('data_query_response.raw')}

          it_should_behave_like "a TNS packet class"
          it_should_behave_like "a TNS packet that can be properly received and parsed"
        end
      end

      context "with packets from the client" do
        context "with a protocol negotiation request" do
          let(:field_values) {{
            :flags => 0x0000,
            :data => raw_packet[10..-1]
          }}
          let(:raw_packet) {TnsSpecHelper.read_message('data_proto_nego_request.raw')}

          it_should_behave_like "a TNS packet class"
          it_should_behave_like "a TNS packet that can be properly created and sent"
        end

        context "with a query request" do
          let(:field_values) {{
            :flags => 0x0000,
            :data => raw_packet[10..-1]
          }}
          let(:raw_packet) {TnsSpecHelper.read_message('data_query_request.raw')}

          it_should_behave_like "a TNS packet class"
          it_should_behave_like "a TNS packet that can be properly created and sent"
        end

        context "with a disconnect message" do
          let(:field_values) {{
            :flags => 0x0040,
            :data => ""
          }}
          let(:raw_packet) {TnsSpecHelper.read_message('data_disconnect.raw')}

          it_should_behave_like "a TNS packet class"
          it_should_behave_like "a TNS packet that can be properly created and sent"
        end
      end
    end
  end
end
