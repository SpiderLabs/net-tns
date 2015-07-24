require "tti_spec_helper"
require "net/tti/message"
require "net/tti/connection"


shared_examples_for "a ProtocolNegotiationResponse that reads properly" do
  subject {Net::TTI::ConnectionParameters.new}

  before :each do
    response = Net::TTI::ProtocolNegotiationResponse.read( binary_string )
    response.populate_connection_parameters( subject )
  end

  its(:proSvrVer) {should == version}
  its(:architecture) {should == architecture}
  its(:platform) {should == platform}
end

module Net::TTI
  describe ProtocolNegotiationResponse do
    context "with a response from a Windows 10g server" do
      it_should_behave_like "a ProtocolNegotiationResponse that reads properly" do
        let(:binary_string) {TtiSpecHelper.read_message("protocol_negotiation_response_windows_10g.raw")}
        let(:version) {6}
        let(:architecture) {:x86}
        let(:platform) {:windows}
      end
    end

    context "with a response from a Windows 11g server" do
      it_should_behave_like "a ProtocolNegotiationResponse that reads properly" do
        let(:binary_string) {TtiSpecHelper.read_message("protocol_negotiation_response_windows_11g.raw")}
        let(:version) {6}
        let(:architecture) {:x86}
        let(:platform) {:windows}
      end
    end

    context "with a response from a Linux 10g server" do
      it_should_behave_like "a ProtocolNegotiationResponse that reads properly" do
        let(:binary_string) {TtiSpecHelper.read_message("protocol_negotiation_response_linux_10g.raw")}
        let(:version) {6}
        let(:architecture) {:x86}
        let(:platform) {:linux}
      end
    end

    context "with a response from a Linux 11g server" do
      it_should_behave_like "a ProtocolNegotiationResponse that reads properly" do
        let(:binary_string) {TtiSpecHelper.read_message("protocol_negotiation_response_linux_11g.raw")}
        let(:version) {6}
        let(:architecture) {:x64}
        let(:platform) {:linux}
      end
    end
  end
end
