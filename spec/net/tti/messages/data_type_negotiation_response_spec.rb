require "tti_spec_helper"
require "net/tti/message"


shared_examples_for "a DataTypeNegotiationResponse that reads properly" do
  it "should read without errors" do
    response = Net::TTI::DataTypeNegotiationResponse.read( binary_string )
    expect(response.data).not_to be_empty
  end
end

module Net::TTI
  describe DataTypeNegotiationResponse do
    context "with a response from a Windows server" do
      it_should_behave_like "a DataTypeNegotiationResponse that reads properly" do
        let(:binary_string) {TtiSpecHelper.read_message("data_type_negotiation_response_windows.raw")}
      end
    end

    context "with a response from a Linux server" do
      it_should_behave_like "a DataTypeNegotiationResponse that reads properly" do
        let(:binary_string) {TtiSpecHelper.read_message("data_type_negotiation_response_linux.raw")}
      end
    end
  end
end
