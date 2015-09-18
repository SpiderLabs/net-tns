require "tti_spec_helper"
require "net/tti/message"


shared_examples_for "a ProtocolNegotiationRequest that functions properly" do
  it "should serialize properly" do
    kvp = Net::TTI::ProtocolNegotiationRequest.create_request()
    kvp.client_versions = versions if versions
    expect(kvp).to eql_binary_string(binary_string)
  end
end

module Net::TTI
  describe ProtocolNegotiationRequest do
    context "with a standard request" do
      it_should_behave_like "a ProtocolNegotiationRequest that functions properly" do
        let(:binary_string) {"0106004c696e7578693338362f4c696e75782d322e302e33342d382e312e3000".tns_unhexify}
        let(:versions) {nil}
      end
    end

    context "with a request with multiple TTC versions" do
      it_should_behave_like "a ProtocolNegotiationRequest that functions properly" do
        let(:binary_string) {"01060504030201004c696e7578693338362f4c696e75782d322e302e33342d382e312e3000".tns_unhexify}
        let(:versions) {[6,5,4,3,2,1]}
      end
    end
  end
end
