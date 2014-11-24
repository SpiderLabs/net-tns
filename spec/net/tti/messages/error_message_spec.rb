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
          let(:binary_string) {("040100000000000100000000f903000000000000000000000000000000000000" +
                            "0000000000000000000000000000000000030000000000003601000000000000" +
                            "b0f3670900000000000000000000000000000000000000000000000000000000" +
                            "334f52412d30313031373a20696e76616c696420757365726e616d652f706173" +
                            "73776f72643b206c6f676f6e2064656e6965640a").tns_unhexify }
          let(:message) {"ORA-01017: invalid username/password; logon denied\n"}
        end
      end

      context "when parsing an account-locked-out error from an Oracle DB 10g server" do
        it_should_behave_like "an ErrorMessage that reads properly" do
          let(:binary_string) {("040100000000000100000000606d000000000000000000000000000000000000" +
                            "0000000000000000000000000000000000030000000000003601000000000000" +
                            "b0f3670900000000000000000000000000000000000000000000000000000000" +
                            "214f52412d32383030303a20746865206163636f756e74206973206c6f636b65" +
                            "640a").tns_unhexify }
          let(:message) {"ORA-28000: the account is locked\n"}
        end
      end

      context "when parsing an error from a 32-bit Oracle DB 10g server on Windows" do
        it_should_behave_like "an ErrorMessage that reads properly" do
          let(:binary_string) {("040100000000000100000000f903000000000000000000000000000000000000" +
                            "0000000000000000000000000000000000030000000000003601000000000000" +
                            "7870e70700000000000000000000000000000000000000000000000000000000" +
                            "334f52412d30313031373a20696e76616c696420757365726e616d652f706173" +
                            "73776f72643b206c6f676f6e2064656e6965640a").tns_unhexify }
          let(:message) {"ORA-01017: invalid username/password; logon denied\n"}
        end
      end

      context "when parsing an error from a 32-bit Oracle DB 11g server on Windows" do
        it_should_behave_like "an ErrorMessage that reads properly" do
          let(:binary_string) {("040100000000000100000000f903000000000000000000000000000000000000" +
                            "0000000000000000000000000000000000030000000000003601000000000000" +
                            "70b1300f00000000000000000000000000000000000000000000000000000000" +
                            "334f52412d30313031373a20696e76616c696420757365726e616d652f706173" +
                            "73776f72643b206c6f676f6e2064656e6965640a").tns_unhexify }
          let(:message) {"ORA-01017: invalid username/password; logon denied\n"}
        end
      end

      context "when parsing an error from a 32-bit Oracle DB 10g server on Linux" do
        it_should_behave_like "an ErrorMessage that reads properly" do
          let(:binary_string) {("0401000000000000000000f90300000000000000000000000000000000000000" +
                            "0000000000000000000000000003000000000000000000000000000000000000" +
                            "0000334f52412d30313031373a20696e76616c696420757365726e616d652f70" +
                            "617373776f72643b206c6f676f6e2064656e6965640a").tns_unhexify }
          let(:message) {"ORA-01017: invalid username/password; logon denied\n"}
        end
      end

      context "when parsing an error from a 64-bit Oracle DB 11g server on Linux" do
        it_should_behave_like "an ErrorMessage that reads properly" do
          let(:binary_string) {("0401000000000000000000f90300000000000000000000000000000000000000" +
                            "0000000000000000000000000003000000000000000000000000000000000000" +
                            "0000334f52412d30313031373a20696e76616c696420757365726e616d652f70" +
                            "617373776f72643b206c6f676f6e2064656e6965640a").tns_unhexify }
          let(:message) {"ORA-01017: invalid username/password; logon denied\n"}
        end
      end
    end
  end
end
