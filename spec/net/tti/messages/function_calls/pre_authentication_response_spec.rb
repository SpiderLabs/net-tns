require "tti_spec_helper"
require "net/tti/message"

shared_examples_for "a PreAuthenticationResponse that reads properly" do |expected_parameters|
  context "when reading" do
    subject {Net::TTI::PreAuthenticationResponse.read( @binary_string )}

    its(:auth_sesskey) {should == @auth_sesskey}
    its(:auth_vfr_data) {should == @auth_vfr_data}

    context "when examining the parameters" do
      it "should have the right number of parameters" do
        expect(subject.parameters.count).to eql(expected_parameters.count)
      end

      expected_parameters.each do |expected_parameter|
        expected_key = expected_parameter[:key]

        it "#{expected_key} should have the right contents" do
          key = subject.parameters.find {|p| p.kvp_key == expected_key}

          expect(key.kvp_key).to eql(expected_parameter[:key])
          expect(key.kvp_value).to eql(expected_parameter[:value])
          expect(key.flags).to eql(expected_parameter[:flags] || 0)
        end
      end
    end
  end
end

module Net
  module TTI
    describe PreAuthenticationResponse do
      context "with a 10g response" do
        before :each do
          @binary_string = ("0802000c0000000c415554485f534553534b4559400000004036453043313832" +
                            "4130373635313742364331304233464343384438393038443943363433313831" +
                            "31454630343646394245464634314241433545414237354537000000000d0000" +
                            "000d415554485f5646525f444154410000000039090000040100000002000100" +
                            "0000000000000000000000000000000000000000000000000000000000000000" +
                            "0000000000000000020000000000003601000000000000b0f367090000000000" +
                            "0000000000000000000000000000000000000000000000").tns_unhexify
          @auth_sesskey = "6E0C182A076517B6C10B3FCC8D8908D9C6431811EF046F9BEFF41BAC5EAB75E7".tns_unhexify
          @auth_vfr_data = ""
        end
        parameters = [
          {:key=>"AUTH_SESSKEY", :value=>"6E0C182A076517B6C10B3FCC8D8908D9C6431811EF046F9BEFF41BAC5EAB75E7"},
          {:key=>"AUTH_VFR_DATA", :value=>"", :flags=>0x0939,},
        ]

        it_should_behave_like "a PreAuthenticationResponse that reads properly", parameters
      end

      context "with an 11g response" do
        before :each do
          @binary_string = ("0803000c0000000c415554485f534553534b455960000000fe40373843313435" +
                            "3133453933333841453832303344334134413033353443414341374235453544" +
                            "4235443836363446354639373930383246443136343538454543204538433844" +
                            "4330373341444446454138304334414145433944323938384133320000000000" +
                            "0d0000000d415554485f5646525f444154411400000014364146354244423432" +
                            "3145383734463738363235251b00001a0000001a415554485f474c4f42414c4c" +
                            "595f554e495155455f4442494400200000002039453134433845383644334534" +
                            "4243453243373039393233383342413236303400000000040100000002000000" +
                            "0000000000000000000000000000000000000000000000000000000000000000" +
                            "00000000020000000000000000000000000000000000000000").tns_unhexify
          @auth_sesskey = "78C14513E9338AE8203D3A4A0354CACA7B5E5DB5D8664F5F979082FD16458EECE8C8DC073ADDFEA80C4AAEC9D2988A32".tns_unhexify
          @auth_vfr_data = "6AF5BDB421E874F78625".tns_unhexify
        end
        parameters = [
          {:key=>"AUTH_SESSKEY", :value=>"78C14513E9338AE8203D3A4A0354CACA7B5E5DB5D8664F5F979082FD16458EECE8C8DC073ADDFEA80C4AAEC9D2988A32"},
          {:key=>"AUTH_VFR_DATA", :value=>"6AF5BDB421E874F78625", :flags=>0x1B25,},
          {:key=>"AUTH_GLOBALLY_UNIQUE_DBID\0", :value=>"9E14C8E86D3E4BCE2C70992383BA2604",},
        ]

        it_should_behave_like "a PreAuthenticationResponse that reads properly", parameters
      end

      context "with an 11g R2 response with no AUTH_VFR_DATA" do
        before :each do
          @binary_string = ("0802000c0000000c415554485f534553534b4559400000004039333339413932" +
                            "4538353831334546383030344341463141373837434243464345373333343237" +
                            "46413731313646464330354235333336324141453635434239000000000d0000" +
                            "000d415554485f5646525f444154410000000039090000040100000002000000" +
                            "0000000000000000000000000000000000000000000000000000000000000000" +
                            "00000000020000000000000000000000000000000000000000").tns_unhexify
          @auth_sesskey = "9339A92E85813EF8004CAF1A787CBCFCE733427FA7116FFC05B53362AAE65CB9".tns_unhexify
          @auth_vfr_data = ""
        end
        parameters = [
          {:key=>"AUTH_SESSKEY", :value=>"9339A92E85813EF8004CAF1A787CBCFCE733427FA7116FFC05B53362AAE65CB9"},
          {:key=>"AUTH_VFR_DATA", :value=>"", :flags=>0x0939,},
        ]

        it_should_behave_like "a PreAuthenticationResponse that reads properly", parameters
      end
    end
  end
end
