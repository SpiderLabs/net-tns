require "tti_spec_helper"
require "net/tti/message"

shared_examples_for "an ErrorMessage that reads properly" do
  context "when reading" do
    subject{Net::TTI::ErrorMessage.read( binary_string )}

    its(:message) {should eql( message )}
  end
end

module Net
  module TTI
    describe ErrorMessage do
      context "when parsing a bad-username/password error from an Oracle DB 10g server" do
        it_should_behave_like "an ErrorMessage that reads properly" do
          let(:binary_string) {("04010100000203f9000000000000000000000000000000000004000000000000334f52412d30313031373a20696e76616c696420757365726e616d652f70617373776f72643b206c6f676f6e2064656e6965640a").tns_unhexify }
          let(:message) {"ORA-01017: invalid username/password; logon denied\n"}
        end
      end

      context "when parsing an account-locked-out error from an Oracle DB 10g server" do
        it_should_behave_like "an ErrorMessage that reads properly" do
          let(:binary_string) {("0401010000026d60000000000000000000000000000000000004000000000000214f52412d32383030303a20746865206163636f756e74206973206c6f636b65640a").tns_unhexify }
          let(:message) {"ORA-28000: the account is locked\n"}
        end
      end

      context "when parsing ORA-01034 error from a Oracle DB 10g server" do
        it_should_behave_like "an ErrorMessage that reads properly" do
          let(:binary_string) {("040101000002040a000000000000000000000000000000000002000000000000804f52412d30313033343a204f5241434c45206e6f7420617661696c61626c650a4f52412d32373130313a20736861726564206d656d6f7279207265616c6d20646f6573206e6f742065786973740a536f6c617269732d414d443634204572726f723a20323a204e6f20737563682066696c65206f72206469726563746f72790a").tns_unhexify }
          let(:message) {"ORA-01034: ORACLE not available\nORA-27101: shared memory realm does not exist\nSolaris-AMD64 Error: 2: No such file or directory\n"}
        end
      end
    end
  end
end
