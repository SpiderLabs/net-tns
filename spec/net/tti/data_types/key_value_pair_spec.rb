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
    let(:flags) {0}

    context "with a simple key-value pair" do
      it_should_behave_like "a KeyValuePair that functions properly" do
        let(:binary_string) {"04000000 0454455354 04000000 0454455354 00000000".tns_unhexify}
        let(:kvp_key) {"TEST"}
        let(:kvp_value) {"TEST"}
      end
    end

    context "with a value with special characters" do
      it_should_behave_like "a KeyValuePair that functions properly" do
        let(:binary_string) {"05000000 055445535432 0e000000 0e544553545c544553543a54455354 00000000".tns_unhexify}
        let(:kvp_key) {"TEST2"}
        let(:kvp_value) {"TEST\\TEST:TEST"}
      end
    end

    context "with a simple key-value pair with flags" do
      it_should_behave_like "a KeyValuePair that functions properly" do
        let(:binary_string) {"04000000 0454455354 04000000 0454455354d2 040000".tns_unhexify}
        let(:kvp_key) {"TEST"}
        let(:kvp_value) {"TEST"}
        let(:flags) {1234}
      end
    end

    context "with a key-value pair with no value" do
      it_should_behave_like "a KeyValuePair that functions properly" do
        let(:binary_string) {"04000000 0454455354 00000000 00000000".tns_unhexify}
        let(:kvp_key) {"TEST"}
        let(:kvp_value) {""}
      end
    end

    context "with an AUTH_SESSKEY key-value pair" do
      it_should_behave_like "a KeyValuePair that functions properly" do
        let(:binary_string) {
          ( "0c0000000c415554485f534553534b455960000000fe40343242363737414536" +
            "3944414639313743364238374538414533383446353941393437354537454644" +
            "3431363833313838444634454632343836363631354231204532373539424538" +
            "3334334634373637313145313444304237314334383534390001000000").tns_unhexify }
        let(:kvp_key) {"AUTH_SESSKEY"}
        let(:kvp_value) {"42B677AE69DAF917C6B87E8AE384F59A9475E7EFD41683188DF4EF24866615B1E2759BE8343F476711E14D0B71C48549"}
        let(:flags) {1}
      end
    end

    context "with an AUTH_ALTER_SESSION key-value pair" do
      # This example is a server response, which includes unknown values. We
      # just need to read it correctly, not be able to build it.
      it_should_behave_like "a KeyValuePair that reads properly" do
        let(:binary_string) {
          ( "1200000012415554485f414c5445525f53455353494f4ee9010000feff414c54" +
            "45522053455353494f4e20534554204e4c535f4c414e47554147453d2027414d" +
            "45524943414e27204e4c535f5445525249544f52593d2027414d455249434127" +
            "204e4c535f43555252454e43593d20272427204e4c535f49534f5f4355525245" +
            "4e43593d2027414d455249434127204e4c535f4e554d455249435f4348415241" +
            "43544552533d20272e2c27204e4c535f43414c454e4441523d2027475245474f" +
            "5249414e27204e4c535f444154455f464f524d41543d202744442d4d4f4e2d52" +
            "5227204e4c535f444154455f4c414e47554147453d2027414d45524943414e27" +
            "204e4c535f534f52543d202742494e415259272054494d455f5a4f4eea453d20" +
            "272d30373a303027204e4c535f434f4d503d202742494e41525927204e4c535f" +
            "4455414c5f43555252454e43593d20272427204e4c535f54494d455f464f524d" +
            "41543d202748482e4d492e535358464620414d27204e4c535f54494d45535441" +
            "4d505f464f524d41543d202744442d4d4f4e2d52522048482e4d492e53535846" +
            "4620414d27204e4c535f54494d455f545a5f464f524d41543d202748482e4d49" +
            "2e535358464620414d20545a5227204e4c535f54494d455354414d505f545a5f" +
            "464f524d41543d202744442d4d4f4e2d52522048482e4d492e53535846462041" +
            "4d20545a5227000000000000" ).tns_unhexify }
        let(:kvp_key) {"AUTH_ALTER_SESSION"}
        let(:kvp_value) {
          "ALTER SESSION SET NLS_LANGUAGE= 'AMERICAN' NLS_TERRITORY= 'AMERICA' " +
          "NLS_CURRENCY= '$' NLS_ISO_CURRENCY= 'AMERICA' NLS_NUMERIC_CHARACTERS= '.,' " +
          "NLS_CALENDAR= 'GREGORIAN' NLS_DATE_FORMAT= 'DD-MON-RR' NLS_DATE_LANGUAGE= 'AMERICAN' " +
          "NLS_SORT= 'BINARY' TIME_ZONE= '-07:00' NLS_COMP= 'BINARY' NLS_DUAL_CURRENCY= '$' " +
          "NLS_TIME_FORMAT= 'HH.MI.SSXFF AM' NLS_TIMESTAMP_FORMAT= 'DD-MON-RR HH.MI.SSXFF AM' " +
          "NLS_TIME_TZ_FORMAT= 'HH.MI.SSXFF AM TZR' NLS_TIMESTAMP_TZ_FORMAT= 'DD-MON-RR HH.MI.SSXFF AM TZR'\x00" }
      end
    end
  end
end
