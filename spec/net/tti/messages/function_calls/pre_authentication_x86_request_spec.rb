require "tti_spec_helper"
require "net/tti/message"

module Net
  module TTI
    describe PreAuthenticationX86 do
      username_only1_x86 = "037602feffffff0600000001000000feffffff00000000fefffffffeffffff0673797374656d".tns_unhexify
      username_only2_x86 = "037602feffffff0400000001000000feffffff00000000fefffffffeffffff0473797374".tns_unhexify
      request1_x86 =       "037602feffffff0600000001000000feffffff01000000fefffffffeffffff0673797374656d0d0000000d415554485f5445524d494e414c0f0000000f54455354484f53542d445936424a3500000000".tns_unhexify
      request2_x86 =       "037602feffffff0600000001000000feffffff02000000fefffffffeffffff0673797374656d0d0000000d415554485f5445524d494e414c0f0000000f54455354484f53542d445936424a35000000000f0000000f415554485f50524f4752414d5f4e4d0b0000000b73716c706c75732e65786500000000".tns_unhexify

      context "when serializing pre-authentication messages" do
        subject {PreAuthenticationX86.new( :username => "system" )}

        before :each do
          subject.sequence_number = 2 # Sequence number in example
        end


        it "should properly serialize a request with no parameters" do
          expect(subject).to eql_binary_string( username_only1_x86 )

          subject.username = "syst"
          expect(subject).to eql_binary_string( username_only2_x86 )
        end

        it "should properly serialize a request with one parameter" do
          subject.add_parameter( "AUTH_TERMINAL", "TESTHOST-DY6BJ5" )

          expect(subject).to eql_binary_string( request1_x86 )
        end

        it "should properly serialize a request with two parameters" do
          subject.add_parameter( "AUTH_TERMINAL", "TESTHOST-DY6BJ5" )
          subject.add_parameter( "AUTH_PROGRAM_NM", "sqlplus.exe" )

          expect(subject).to eql_binary_string( request2_x86 )
        end
      end
    end
  end
end
