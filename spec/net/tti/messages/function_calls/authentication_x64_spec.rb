require "tti_spec_helper"
require "net/tti/message"

module Net
  module TTI
    describe AuthenticationX64 do
      auth_request_x64 = (
        "037303011200000001010000010200000001010673797374656d0c0000000c41" +
        "5554485f534553534b4559400000004033373933334530453244353733333243" +
        "3839463734413030454544313346423045313441343743354437394535343931" +
        "39444331324632343941394639353043010000000d0000000d415554485f5041" +
        "5353574f52444000000040304144313141414636344441343435464538424632" +
        "3741313144343632343442314130323645353145413944393935303336373633" +
        "324142444532443244453400000000" ).tns_unhexify

      context "when serializing authentication messages" do
        subject {AuthenticationX64.new( :username => "system" )}

        before :each do
          subject.sequence_number = 3 # Sequence number in example
        end

        it "should properly serialize an x64 authentication request" do
          subject.enc_client_session_key = "37933E0E2D57332C89F74A00EED13FB0E14A47C5D79E54919DC12F249A9F950C".tns_unhexify
          subject.enc_password = "0AD11AAF64DA445FE8BF27A11D46244B1A026E51EA9D9950367632ABDE2D2DE4".tns_unhexify

          expect(subject.to_binary_s).to eql_binary_string( auth_request_x64 )
        end

        it "should properly serialize an x64 authentication request when calling #add_parameter" do
          subject.add_parameter( "AUTH_SESSKEY", "37933E0E2D57332C89F74A00EED13FB0E14A47C5D79E54919DC12F249A9F950C", 1 )
          subject.add_parameter( "AUTH_PASSWORD", "0AD11AAF64DA445FE8BF27A11D46244B1A026E51EA9D9950367632ABDE2D2DE4" )

          expect(subject.to_binary_s).to eql_binary_string( auth_request_x64 )
        end
      end
    end
  end
end
