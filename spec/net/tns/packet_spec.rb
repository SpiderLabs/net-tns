require "net/tns/packet_spec_helper"
require 'net/tns/packet'

module Net::TNS
  describe Header do
    test_data = [
      { :length => 1,
        :binary_string => "0001000000000000".tns_unhexify, },
      { :length => 512,
        :binary_string => "0200000000000000".tns_unhexify, },
      { :packet_type_code => 1, :packet_type => "Connect",
        :binary_string => "0000000001000000".tns_unhexify, },
      { :packet_type_code => 2, :packet_type => "Accept",
        :binary_string => "0000000002000000".tns_unhexify, },
      { :packet_type_code => 3, :packet_type => "Ack",
        :binary_string => "0000000003000000".tns_unhexify, },
      { :packet_type_code => 4, :packet_type => "Refuse",
        :binary_string => "0000000004000000".tns_unhexify, },
      { :packet_type_code => 5, :packet_type => "Redirect",
        :binary_string => "0000000005000000".tns_unhexify, },
      { :packet_type_code => 6, :packet_type => "Data",
        :binary_string => "0000000006000000".tns_unhexify, },
      { :packet_type_code => 7, :packet_type => "Null",
        :binary_string => "0000000007000000".tns_unhexify, },
      { :packet_type_code => 9, :packet_type => "Abort",
        :binary_string => "0000000009000000".tns_unhexify, },
      { :packet_type_code => 11, :packet_type => "Resend",
        :binary_string => "000000000b000000".tns_unhexify, },
      { :packet_type_code => 12, :packet_type => "Marker",
        :binary_string => "000000000c000000".tns_unhexify, },
      { :packet_type_code => 13, :packet_type => "Attention",
        :binary_string => "000000000d000000".tns_unhexify, },
      { :packet_type_code => 14, :packet_type => "Control",
        :binary_string => "000000000e000000".tns_unhexify, },
      { :packet_type_code => 1, :packet_type => "Connect",
        :length => 40,
        :binary_string => "0028000001000000".tns_unhexify, },
    ]


    test_data.each do | test_info |
      context "with length #{test_info[:length] or "nil"} and type #{test_info[:packet_type] or "nil"}" do
        it "should generate the correct binary string for the header" do
          subject.packet_length = test_info[:length] unless test_info[:length].nil?
          subject.packet_type = test_info[:packet_type_code] unless test_info[:packet_type_code].nil?

          expect(subject).to eql_binary_string( test_info[:binary_string] )
        end

        context "when parsing a binary string" do
          before :each do
            subject.read( test_info[:binary_string] )
          end

          its(:packet_length) {eql(test_info[:length] || 0)}
          its(:packet_type) {eql(test_info[:packet_type_code] || 0)}
        end
      end
    end
  end
end


