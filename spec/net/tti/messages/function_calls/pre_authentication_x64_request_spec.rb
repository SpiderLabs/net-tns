require "tti_spec_helper"
require "net/tti/message"

module Net
  module TTI
    describe PreAuthenticationX64 do
      username_only1_x64 = "037602011200000001000000010000000001010673797374656d".tns_unhexify
      username_only2_x64 = "037602011200000001000000010000000001010473797374".tns_unhexify
      request1_x64 =       "037602011200000001000000010100000001010673797374656d0d0000000d415554485f5445524d494e414c0f0000000f54455354484f53542d445936424a3500000000".tns_unhexify
      request2_x64 =       "037602011200000001000000010200000001010673797374656d0d0000000d415554485f5445524d494e414c0f0000000f54455354484f53542d445936424a35000000000f0000000f415554485f50524f4752414d5f4e4d0b0000000b73716c706c75732e65786500000000".tns_unhexify

      context "when serializing pre-authentication requests" do
        subject {PreAuthenticationX64.new( :username => "system" )}

        before :each do
          subject.sequence_number = 2 # Sequence number in example
        end

        it "should properly serialize a request with no parameters" do
          expect(subject.to_binary_s).to eql_binary_string( username_only1_x64 )

          subject.username = "syst"
          expect(subject.to_binary_s).to eql_binary_string( username_only2_x64 )
        end

        it "should properly serialize a request with one parameter" do
          subject.add_parameter( "AUTH_TERMINAL", "TESTHOST-DY6BJ5" )

          expect(subject.to_binary_s).to eql_binary_string( request1_x64 )
        end

        it "should properly serialize a request with two parameters" do
          subject.add_parameter( "AUTH_TERMINAL", "TESTHOST-DY6BJ5" )
          subject.add_parameter( "AUTH_PROGRAM_NM", "sqlplus.exe" )

          expect(subject.to_binary_s).to eql_binary_string( request2_x64 )
        end
      end
    end
  end
end
