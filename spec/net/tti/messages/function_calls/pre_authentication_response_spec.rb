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
          @binary_string = ("080102010c0c415554485f534553534b45590140403930303739333939313736" + 
                            "3642423930323646453138453941373030383732324633424345413535463334" + 
                            "35423932464636343639323637303538343939354500010d0d415554485f5646" +
                            "525f444154410001090401010102000000000000000000000000000000000000" + 
                            "0000020000000000").tns_unhexify
          @auth_sesskey = "900793991766BB9026FE18E9A7008722F3BCEA55F345B92FF64692670584995E".tns_unhexify
          @auth_vfr_data = ""
        end
        parameters = [
          {:key=>"AUTH_SESSKEY", :value=>"900793991766BB9026FE18E9A7008722F3BCEA55F345B92FF64692670584995E"},
          {:key=>"AUTH_VFR_DATA", :value=>"", :flags=>9},
        ]

        it_should_behave_like "a PreAuthenticationResponse that reads properly", parameters
      end

      context "with an 11g response" do
        before :each do
          @binary_string = ("080103010C0C415554485F534553534B45590160604336374444454432354333" +
                            "3431353943313937434544383533373546333032444443433939314239354242" +
                            "4534454142363233433835443135433444423442413631373532433736323643" +
                            "34463143443245353145324544303445424335413600010D0D415554485F5646" +
                            "525F444154410114143638383736353037463035434445383644304436021B25" +
                            "011A1A415554485F474C4F42414C4C595F554E495155455F4442494400012020" +
                            "4337363744304239463736433446354646383942463445374238344438353832" +
                            "0004010101020000000000000000000000000000000000000001000000000000").tns_unhexify

          @auth_sesskey = "C67DDED25C34159C197CED85375F302DDCC991B95BBE4EAB623C85D15C4DB4BA61752C7626C4F1CD2E51E2ED04EBC5A6".tns_unhexify
          @auth_vfr_data = "68876507F05CDE86D0D6".tns_unhexify
        end
        parameters = [
          {:key=>"AUTH_SESSKEY", :value=>"C67DDED25C34159C197CED85375F302DDCC991B95BBE4EAB623C85D15C4DB4BA61752C7626C4F1CD2E51E2ED04EBC5A6"},
          {:key=>"AUTH_VFR_DATA", :value=>"68876507F05CDE86D0D6", :flags=>0x1B25,},
          {:key=>"AUTH_GLOBALLY_UNIQUE_DBID\0", :value=>"C767D0B9F76C4F5FF89BF4E7B84D8582",},
        ]

        it_should_behave_like "a PreAuthenticationResponse that reads properly", parameters
      end
    end
  end
end
