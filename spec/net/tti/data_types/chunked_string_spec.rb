require "tti_spec_helper"
require "net/tti/data_types"

shared_examples_for "a ChunkedString that functions properly" do
  it "should serialize properly" do
    clr_string = Net::TTI::DataTypes::ChunkedString.new( data )
    expect(clr_string.to_binary_s).to eql_binary_string( binary_string )
  end

  it "should read properly" do
    clr_string = Net::TTI::DataTypes::ChunkedString.read( binary_string )
    expect(clr_string).to eql( data )
  end
end

module Net::TTI::DataTypes
  describe ChunkedString do
    context "with a simple string" do
      it_should_behave_like "a ChunkedString that functions properly" do
        let(:data) {"ABCD"}
        let(:binary_string) {"0441424344".tns_unhexify}
      end
    end

    context "with an empty string" do
      it_should_behave_like "a ChunkedString that functions properly" do
        let(:data) {""}
        let(:binary_string) {"".tns_unhexify}
      end
    end

    context "with a string with null characters" do
      it_should_behave_like "a ChunkedString that functions properly" do
        let(:data) {"TEST\0"}
        let(:binary_string) {"055445535400".tns_unhexify}
      end
    end

    context "with a string with 64 characters" do
      it_should_behave_like "a ChunkedString that functions properly" do
        let(:data) {"0123456789012345678901234567890123456789012345678901234567890123"}
        let(:binary_string) {"4030313233343536373839303132333435363738393031323334353637383930313233343536373839303132333435363738393031323334353637383930313233".tns_unhexify}
      end
    end

    context "with a string with 65 characters" do
      it_should_behave_like "a ChunkedString that functions properly" do
        let(:data) {"01234567890123456789012345678901234567890123456789012345678901234"}
        let(:binary_string) {"fe4030313233343536373839303132333435363738393031323334353637383930313233343536373839303132333435363738393031323334353637383930313233013400".tns_unhexify}
      end
    end
  end
end
