require "tns_spec_helper"
require 'net/tns/connection'

module Net::TNS
  module ConnectionSpecHelper
    def self.get_fake_socket_proc
      return Proc.new {@last_socket = SpecHelpers::FakeSocket.new}
    end

    def self.current_socket
      @last_socket
    end

    def self.reset_current_socket
      @last_socket = nil
    end
  end

  describe Connection do
    context "when creating a socket" do
      it "should create a connection with a host and port" do
        expect {Connection.new(:host=>"127.0.0.1", :port=>12345)}.not_to raise_error
      end

      it "should create a connection with only a host" do
        expect {Connection.new(:host=>"127.0.0.1")}.not_to raise_error
      end

      it "should create a connection with only a new-socket proc" do
        proc = ConnectionSpecHelper.get_fake_socket_proc
        expect {Connection.new(:new_socket_proc => proc)}.not_to raise_error
      end
    end

    context "with a fake socket" do
      before :each do
        ConnectionSpecHelper.reset_current_socket
      end
      subject {Connection.new(:new_socket_proc => ConnectionSpecHelper.get_fake_socket_proc)}

      context "when calling #open_socket" do
        it "should call the new-socket proc" do
          expect(ConnectionSpecHelper.current_socket).to be_nil
          subject.open_socket()
          expect(ConnectionSpecHelper.current_socket).not_to be_nil
          expect(ConnectionSpecHelper.current_socket).not_to be_closed
        end
      end

      context "when calling #close_socket" do
        it "should close an open socket" do
          subject.open_socket()
          expect(ConnectionSpecHelper.current_socket).not_to be_closed
          subject.close_socket()
          expect(ConnectionSpecHelper.current_socket).to be_closed
        end

        it "should not error if the socket has already been closed" do
          subject.open_socket()
          subject.close_socket()
          expect(ConnectionSpecHelper.current_socket).to be_closed
          expect { subject.close_socket() }.not_to raise_error
          expect(ConnectionSpecHelper.current_socket).to be_closed
        end

        it "should not error if the socket has not been opened" do
          expect { subject.close_socket() }.not_to raise_error
        end
      end

      context "with an open socket" do
        before :each do
          subject.open_socket()
        end

        context "when calling #send_tns_packet" do
          it "should properly send the packet" do
            packet = Net::TNS::DataPacket.new(:data => "foo bar baz")
            subject.send_tns_packet(packet)
            expect( ConnectionSpecHelper.current_socket._written_data ).to eql_binary_string( packet )
          end
        end

        context "when calling #receive_tns_packet" do
          it "should properly receive a packet" do
            packet1 = Net::TNS::DataPacket.new(:data => "foo bar")
            packet2 = Net::TNS::DataPacket.new(:data => "foo baz")
            ConnectionSpecHelper.current_socket._queue_response( packet1 )
            ConnectionSpecHelper.current_socket._queue_response( packet2 )

            expect( subject.receive_tns_packet() ).to eql_binary_string( packet1 )
            expect( ConnectionSpecHelper.current_socket._has_unread_data? ).to eql(true)
            expect( subject.receive_tns_packet() ).to eql_binary_string( packet2 )
            expect( ConnectionSpecHelper.current_socket._has_unread_data? ).to eql(false)
          end

          it "should properly handle a Resend" do
            fake_socket = ConnectionSpecHelper.current_socket
            # Send a packet so there's one to be re-sent
            request_packet = Net::TNS::DataPacket.new(:data => "foo bar")
            subject.send_tns_packet(request_packet)

            # Queue up the resend and the eventual real response
            response_packet = Net::TNS::DataPacket.new(:data => "foo baz")
            fake_socket._queue_response( Net::TNS::ResendPacket.new )
            fake_socket._queue_response( response_packet )

            fake_socket._clear_written_data!
            expect( fake_socket._has_unread_data? ).to eql(true)
            expect( fake_socket._written_data ).to be_empty

            expect( subject.receive_tns_packet() ).to eql_binary_string(response_packet)

            expect( fake_socket._has_unread_data? ).to eql(false)
            expect( fake_socket._written_data ).to eql_binary_string( request_packet )
          end

          it "should properly handle a Refuse" do
            fake_socket = ConnectionSpecHelper.current_socket

            # Queue up the resend and the eventual real response
            fake_socket._queue_response( Net::TNS::RefusePacket.new )

            expect {subject.receive_tns_packet()}.to raise_error(Exceptions::RefuseMessageReceived)

            expect( fake_socket._has_unread_data? ).to eql(false)
            expect( fake_socket._written_data ).to be_empty
          end

          it "should properly handle a Redirect" do
            pending "Implementation of redirect handling"
            fake_socket = ConnectionSpecHelper.current_socket

            # Queue up the resend and the eventual real response
            fake_socket._queue_response( Net::TNS::RedirectPacket.new )

            expect {subject.receive_tns_packet()}.to raise_error(Exceptions::RedirectMessageReceived)

            expect( fake_socket._has_unread_data? ).to eql(false)
            expect( fake_socket._written_data ).to be_empty
          end
        end

        context "when calling #send_and_receive" do
          it "should send and then receive" do
            request_packet = Net::TNS::DataPacket.new(:data => "foo bar")
            response_packet = Net::TNS::DataPacket.new(:data => "foo baz")

            expect(subject).to receive(:send_tns_packet).ordered.with(request_packet)
            expect(subject).to receive(:receive_tns_packet).ordered.and_return(response_packet)

            expect(subject.send_and_receive(request_packet)).to eql(response_packet)
          end
        end

        context "when calling #connect" do
          it "should raise an error if neither :sid nor :service_name is given" do
            expect { subject.connect() }.to raise_error(ArgumentError)
          end

          it "should raise an error if both :sid and :service_name are given" do
            expect { subject.connect(:sid=>"TEST", :service_name=>"TEST") }.to raise_error(ArgumentError)
          end

          it "should properly handle connecting by SID" do
            fake_socket = ConnectionSpecHelper.current_socket
            accept_response = TnsSpecHelper.read_message('accept.raw')
            ano_response = TnsSpecHelper.read_message('ano_negotiation_response.raw')

            fake_socket._queue_response(accept_response)
            fake_socket._queue_response(ano_response)

            subject.connect(:sid => "TEST")

            expected_ano_request_data = (
              "deadbeef00920a2001000004000004000300000000000400050a200100000800" +
              "0100000b58884d7db000120001deadbeef000300000004000400010001000200" +
              "01000300000000000400050a20010000020003e0e100020006fcff0002000200" +
              "000000000400050a200100000c0001001106100c0f0a0b080201030003000200" +
              "000000000400050a20010000030001000301").tns_unhexify
            expect(fake_socket._written_data).to eql_binary_string(
              Net::TNS::ConnectPacket.make_connection_by_sid( "127.0.0.1", "1521", "TEST" ).to_binary_s +
              Net::TNS::DataPacket.new( :data => expected_ano_request_data ).to_binary_s # there's more, but this is all we're speccing
              )
          end

          it "should properly handle connecting by service name" do
            fake_socket = ConnectionSpecHelper.current_socket
            accept_response = TnsSpecHelper.read_message('accept.raw')
            ano_response = TnsSpecHelper.read_message('ano_negotiation_response.raw')

            fake_socket._queue_response(accept_response)
            fake_socket._queue_response(ano_response)

            subject.connect(:service_name => "TEST")

            expected_ano_request_data = (
              "deadbeef00920a2001000004000004000300000000000400050a200100000800" +
              "0100000b58884d7db000120001deadbeef000300000004000400010001000200" +
              "01000300000000000400050a20010000020003e0e100020006fcff0002000200" +
              "000000000400050a200100000c0001001106100c0f0a0b080201030003000200" +
              "000000000400050a20010000030001000301").tns_unhexify
            expect(fake_socket._written_data).to eql_binary_string(
              Net::TNS::ConnectPacket.make_connection_by_service_name( "127.0.0.1", "1521", "TEST" ).to_binary_s +
              Net::TNS::DataPacket.new( :data => expected_ano_request_data ).to_binary_s # there's more, but this is all we're speccing
              )
          end
        end
      end
    end
  end
end
