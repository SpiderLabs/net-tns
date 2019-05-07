require 'net/tns/client'

module Net
  module TNS
    describe Client do
      let(:vsnnum) { '301989888' }

      describe "::parse_vsnnum" do
        context "when provided a valid VSNNUM string" do
          it "should return the correct version" do
            expect(Client.parse_vsnnum(vsnnum)).to eql('18.0.0.0.0')
          end
        end
        context "when provided a non-string" do
          it "should raise an error" do
            expect { Client.parse_vsnnum(12345678) }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
