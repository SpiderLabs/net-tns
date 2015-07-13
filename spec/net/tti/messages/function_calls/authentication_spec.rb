require "tti_spec_helper"
require "net/tti/message"

module Net
  module TTI
    describe Authentication do
      auth_request = (
        "037303feffffff0600000001010000feffffff02000000fefffffffeffffff06" +
        "73797374656d0c0000000c415554485f534553534b4559400000004033373933" +
        "3345304532443537333332433839463734413030454544313346423045313441" +
        "3437433544373945353439313944433132463234394139463935304301000000" +
        "0d0000000d415554485f50415353574f52444000000040304144313141414636" +
        "3444413434354645384246323741313144343632343442314130323645353145" +
        "413944393935303336373633324142444532443244453400000000" ).tns_unhexify

      context "when serializing authentication messages" do
        subject {Authentication.new( :username => "system" )}

        before :each do
          subject.sequence_number = 3 # Sequence number in example
        end

        it "should properly serialize authentication request" do
          subject.enc_client_session_key = "37933E0E2D57332C89F74A00EED13FB0E14A47C5D79E54919DC12F249A9F950C".tns_unhexify
          subject.enc_password = "0AD11AAF64DA445FE8BF27A11D46244B1A026E51EA9D9950367632ABDE2D2DE4".tns_unhexify

          expect(subject).to eql_binary_string( auth_request )
        end

        it "should properly serialize authentication request when calling #add_parameter" do
          subject.add_parameter( "AUTH_SESSKEY", "37933E0E2D57332C89F74A00EED13FB0E14A47C5D79E54919DC12F249A9F950C", 1 )
          subject.add_parameter( "AUTH_PASSWORD", "0AD11AAF64DA445FE8BF27A11D46244B1A026E51EA9D9950367632ABDE2D2DE4" )

          expect(subject).to eql_binary_string( auth_request )
        end
      end
    end
  end
end
