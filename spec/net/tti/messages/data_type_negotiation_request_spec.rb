require "tti_spec_helper"
require "net/tti/message"


shared_examples_for "a DataTypeNegotiationRequest that functions properly" do
  it "should serialize properly" do
    kvp = Net::TTI::DataTypeNegotiationRequest.create_request(platform)
    expect(kvp.to_binary_s).to eql_binary_string(binary_string)
  end
end

module Net::TTI
  describe DataTypeNegotiationRequest do
    context "with a request for a Windows server" do
      it_should_behave_like "a DataTypeNegotiationRequest that functions properly" do
        let(:binary_string) {TtiSpecHelper.read_message("data_type_negotiation_request_windows_10g.raw")}
        let(:platform) {:windows}
      end
    end

    context "with a request for a Linux server" do
      it_should_behave_like "a DataTypeNegotiationRequest that functions properly" do
        let(:binary_string) {TtiSpecHelper.read_message("data_type_negotiation_request_linux.raw")}
        let(:platform) {:linux}
      end
    end
  end
end
