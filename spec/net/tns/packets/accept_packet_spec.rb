require "net/tns/packet_spec_helper"

module Net
  module TNS
    describe AcceptPacket do
      let(:tns_type) {2}

      describe "with an empty accept message" do
        let(:field_values) {{
          :version => 0x0134,
          :service_flags => 0x0000,
          :sdu_size => 0x0800,
          :maximum_tdu_size => 0x7fff,
          :byte_order => 256,
          :data_length => 0,
          :data_offset => 24,
          :flags1 => 65,
          :flags2 => 1,
          :data => ""
        }}
        let(:raw_packet) {TnsSpecHelper.read_message('accept.raw')}

        it_should_behave_like "a TNS packet class"
        it_should_behave_like "a TNS packet that can be properly received and parsed"
      end

      describe "with an accept message with connection data" do
        let(:field_values) {Hash.new(
          :version => 0x0134,
          :service_flags => 0x0001,
          :sdu_size => 0x0800,
          :maximum_tdu_size => 0x7fff,
          :byte_order => 0x0100,
          :data_length => 45,
          :data_offset => 24,
          :flags1 => 13,
          :flags2 => 1,
          :data => "(DESCRIPTION=(TMP=)(VSNNUM=169869568)(ERR=0))"
        )}
        let(:raw_packet) {TnsSpecHelper.read_message('accept_with_data.raw')}

        it_should_behave_like "a TNS packet class"
        it_should_behave_like "a TNS packet that can be properly received and parsed"
      end
    end
  end
end
