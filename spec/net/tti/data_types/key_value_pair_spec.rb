require "tti_spec_helper"
require "net/tti/data_types"


shared_examples_for "a KeyValuePair that reads properly" do
  subject {Net::TTI::DataTypes::KeyValuePair.read( binary_string )}

  its(:kvp_key) {should == kvp_key}
  its(:kvp_value) {should == kvp_value}
  its(:flags) {should == flags}
end

shared_examples_for "a KeyValuePair that functions properly" do
  it "should serialize properly when built from #initialize arguments" do
    kvp = Net::TTI::DataTypes::KeyValuePair.new( :kvp_key => kvp_key, :kvp_value => kvp_value, :flags => flags )
    expect(kvp.to_binary_s).to eql(binary_string)
  end

  it "should serialize properly when built from accessors" do
    kvp = Net::TTI::DataTypes::KeyValuePair.new
    kvp.kvp_key = kvp_key
    kvp.kvp_value = kvp_value
    kvp.flags = flags

    expect(kvp.to_binary_s).to eql(binary_string)
  end

  it_should_behave_like "a KeyValuePair that reads properly"
end

module Net::TTI::DataTypes
  describe KeyValuePair do
    let(:flags) {0x00}

    context "with a simple key-value pair" do
      it_should_behave_like "a KeyValuePair that functions properly" do
        let(:binary_string) {"010d0d415554485f5445524d494e414c010707756e6b6e6f776e00".tns_unhexify}
        let(:kvp_key) {"AUTH_TERMINAL"}
        let(:kvp_value) {"unknown"}
        let(:flags) {0x00}
      end
    end

    context "with a value with special characters" do
      it_should_behave_like "a KeyValuePair that functions properly" do
        let(:binary_string) {"0105055445535432010e0e544553545c544553543a5445535400".tns_unhexify}
        let(:kvp_key) {"TEST2"}
        let(:kvp_value) {"TEST\\TEST:TEST"}
      end
    end

    context "with a simple key-value pair with flags" do
      it_should_behave_like "a KeyValuePair that functions properly" do
        let(:binary_string) {"01040454455354010404544553540144".tns_unhexify}
        let(:kvp_key) {"TEST"}
        let(:kvp_value) {"TEST"}
        let(:flags) {68}
      end
    end

    context "with a key-value pair with no value" do
      it_should_behave_like "a KeyValuePair that functions properly" do
        let(:binary_string) {"01040454455354010000".tns_unhexify}
        let(:kvp_key) {"TEST"}
        let(:kvp_value) {""}
      end
    end

    context "with an AUTH_SESSKEY key-value pair" do
      it_should_behave_like "a KeyValuePair that functions properly" do
        let(:binary_string) {
          ( "010c0c415554485f534553534b45590140403938313146433737383734314141" + 
            "4344304438433335324232333941373939383745423944374544324231413536" + 
            "4245444239383430334341333535443634300101").tns_unhexify }
        let(:kvp_key) {"AUTH_SESSKEY"}
        let(:kvp_value) {"9811FC778741AACD0D8C352B239A79987EB9D7ED2B1A56BEDB98403CA355D640"}
        let(:flags) {1}
      end
    end

    context "with an AUTH_ALTER_SESSION key-value pair" do
      # This example is a server response, which includes unknown values. We
      # just need to read it correctly, not be able to build it.
      it_should_behave_like "a KeyValuePair that reads properly" do
        let(:binary_string) {
          ( "011212415554485f414c5445525f53455353494f4e015ffe40414c5445522053" +
            "455353494f4e205345542054494d455f5a4f4e453d27416d65726963612f4e65" + 
            "775f596f726b27204e4c535f4c414e47554147453d27414d451f524943414e27" + 
            "204e4c535f5445525249544f52593d27414d45524943412700000101" ).tns_unhexify }
        let(:kvp_key) {"AUTH_ALTER_SESSION"}
        let(:kvp_value) {
          "ALTER SESSION SET TIME_ZONE='America/New_York' NLS_LANGUAGE='AMERICAN' NLS_TERRITORY='AMERICA'\x00" }
        let(:flags) { 0x01 }
      end
    end
  end
end
