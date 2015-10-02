require "tti_spec_helper"
require "net/tti/message"

module Net
  module TTI
    describe Authentication do
      auth_request = (
        "037304010106020101010103010173797374656d010d0d415554485f50415353" +
        "574f524401404046343638364543394337303541313145343930434337303031" +
        "3431313038453431393136343130374643423342364237434431393346363045" +
        "4532433235354600010d0d415554485f5445524d494e414c010707756e6b6e6f" +
        "776e00010c0c415554485f534553534b45590140404332344242313730423644" +
        "4635394431304239434439453835363841314334453342433438463946454438" +
        "3338363933464136323035304231444332463937410101" ).tns_unhexify

      context "when serializing authentication messages" do
        subject {Authentication.new( :username => "system" )}

        before :each do
          subject.sequence_number = 4 # Sequence number in example
        end

        it "should properly serialize authentication request" do
          subject.enc_password = "F4686EC9C705A11E490CC700141108E419164107FCB3B6B7CD193F60EE2C255F".tns_unhexify
          subject.add_parameter("AUTH_TERMINAL", "unknown")
          subject.enc_client_session_key = "C24BB170B6DF59D10B9CD9E8568A1C4E3BC48F9FED838693FA62050B1DC2F97A".tns_unhexify

          expect(subject).to eql_binary_string( auth_request )
        end

        it "should properly serialize authentication request when calling #add_parameter" do
          subject.add_parameter( "AUTH_PASSWORD", "F4686EC9C705A11E490CC700141108E419164107FCB3B6B7CD193F60EE2C255F" )
          subject.add_parameter("AUTH_TERMINAL", "unknown")
          subject.add_parameter( "AUTH_SESSKEY", "C24BB170B6DF59D10B9CD9E8568A1C4E3BC48F9FED838693FA62050B1DC2F97A", 1 )

          expect(subject).to eql_binary_string( auth_request )
        end
      end
    end
  end
end
