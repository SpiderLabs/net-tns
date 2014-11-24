module Net
  module TTI
    class ProtocolNegotiationResponse < Message
      handles_response_for_ttc_code TTC_CODE_PROTOCOL_NEGOTIATION

      # BinData fields
      stringz   :versions_string  # The protocol (TTC?) version negotiated
      stringz   :protocol_handler
      uint16le  :character_set

      uint8     :unknown1
      uint16le  :unknown2_length
      string    :unknown2,  :read_length => lambda {unknown2_length * 5}
      uint16be  :unknown3_length
      string    :unknown3,  :read_length => :unknown3_length
      uint8     :unknown4_length
      string    :unknown4,  :read_length => :unknown4_length
      uint8     :unknown5_length
      string    :unknown5,  :read_length => :unknown5_length

      def version
        self.versions_string[0,1].unpack("C").first
      end

      def populate_connection_parameters( conn_params )
        conn_params.ttc_version = self.version

        case self.protocol_handler
        when "IBMPC/WIN_NT-8.1.0"
          conn_params.architecture = :x86
          conn_params.platform = :windows
        when "Linuxi386/Linux-2.0.34-8.1.0"
          conn_params.architecture = :x86
          conn_params.platform = :linux
        when "x86_64/Linux 2.4.xx"
          conn_params.architecture = :x64
          conn_params.platform = :linux
        else
          raise Net::TTI::Exceptions::UnsupportedPlatform.new( self.protocol_handler )
        end
      end
    end
  end
end
