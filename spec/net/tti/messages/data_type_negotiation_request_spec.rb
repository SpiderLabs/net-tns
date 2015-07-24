require "tti_spec_helper"
require "net/tti/message"


shared_examples_for "a DataTypeNegotiationRequest that functions properly" do
  it "should serialize properly" do
    conn_params.proSvrVer = 6
    conn_params.svrCharSet = 0xb2
    conn_params.svrFlags = 0x1
    conn_params.svrCompiletimeCapabilities = "\x06\x01\x01\x01\x0f\x01\x01\x06\x01\x01\x01\x01\x01\x01\x01\x7f\xff\x03\n\x03\a\x01\x01\x7f\x01\x7f\xff\x01\t\x01\x01\xbf\x01\x05\x06\x00\x01\a\x04"
    conn_params.svrRuntimeCapabilities = "\x02\x01\x00\x01\x18\x00\x03"
    kvp = Net::TTI::DataTypeNegotiationRequest.create_request(conn_params)
    expect(kvp).to eql_binary_string(binary_string)
  end
end

module Net::TTI
  describe DataTypeNegotiationRequest do
    context "with a request for a 11g2 server" do
      it_should_behave_like "a DataTypeNegotiationRequest that functions properly" do
        let(:conn_params) { Net::TTI::ConnectionParameters.new() }
        let(:binary_string) {TtiSpecHelper.read_message("data_type_negotiation_request_solaris_11g2.raw")}
      end
    end

# TODO: fix this by passing conn_params with correct Capabilities for 10g
#    context "with a request for a 10g2 server" do
#      it_should_behave_like "a DataTypeNegotiationRequest that functions properly" do
#        let(:conn_params) { Net::TTI::ConnectionParameters.new() }
#        let(:binary_string) {TtiSpecHelper.read_message("data_type_negotiation_request_solaris_10g2.raw")}
#      end
#    end
  end
end
