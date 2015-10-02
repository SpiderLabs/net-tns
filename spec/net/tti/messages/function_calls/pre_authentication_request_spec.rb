require "tti_spec_helper"
require "net/tti/message"

module Net
  module TTI
    describe PreAuthentication do
      username_only1 = "0376020101060101010100010173797374656d".tns_unhexify
      username_only2 = "0376020101040101010100010173797374".tns_unhexify
      request1 =       "0376020101060101010101010173797374656d010d0d415554485f5445524d494e414c010f0f54455354484f53542d445936424a3500".tns_unhexify
      request2 =       "0376020101060101010102010173797374656d010d0d415554485f5445524d494e414c010f0f54455354484f53542d445936424a3500010f0f415554485f50524f4752414d5f4e4d010b0b73716c706c75732e65786500".tns_unhexify

      context "when serializing pre-authentication messages" do
        subject {PreAuthentication.new( :username => "system" )}

        before :each do
          subject.sequence_number = 2 # Sequence number in example
        end


        it "should properly serialize a request with no parameters" do
          expect(subject).to eql_binary_string( username_only1 )

          subject.username = "syst"
          expect(subject).to eql_binary_string( username_only2 )
        end

        it "should properly serialize a request with one parameter" do
          subject.add_parameter( "AUTH_TERMINAL", "TESTHOST-DY6BJ5" )

          expect(subject).to eql_binary_string( request1 )
        end

        it "should properly serialize a request with two parameters" do
          subject.add_parameter( "AUTH_TERMINAL", "TESTHOST-DY6BJ5" )
          subject.add_parameter( "AUTH_PROGRAM_NM", "sqlplus.exe" )

          expect(subject).to eql_binary_string( request2 )
        end
      end
    end
  end
end
