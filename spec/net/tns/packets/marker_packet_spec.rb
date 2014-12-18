require "net/tns/packet_spec_helper"

module Net
  module TNS
    describe MarkerPacket do
      let(:tns_type) {12}

      context "with a marker from the server" do
        let(:field_values) {{
          :marker_type => 1,
          :data => "0001".tns_unhexify
        }}
        let(:raw_packet) {TnsSpecHelper.read_message('marker_response.raw')}

        it_should_behave_like "a TNS packet class"
        it_should_behave_like "a TNS packet that can be properly received and parsed"
      end

      context "with a marker from the client" do
        let(:field_values) {{
            :marker_type => 1,
            :data => "0002".tns_unhexify
        }}
        let(:raw_packet) {TnsSpecHelper.read_message('marker_request.raw')}

        it_should_behave_like "a TNS packet class"
        it_should_behave_like "a TNS packet that can be properly created and sent"
      end

      context "with a marker from the client" do
        let(:field_values) {{
            :marker_type => 1,
            :data => "0002".tns_unhexify
        }}
        let(:raw_packet) {MarkerPacket.create_request().to_binary_s}

        it_should_behave_like "a TNS packet class"
        it_should_behave_like "a TNS packet that can be properly created and sent"
      end
    end
  end
end
