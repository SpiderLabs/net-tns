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

        if self.protocol_handler.start_with?("IBMPC/WIN_NT-")
          conn_params.architecture = :x86
          conn_params.platform = :windows
        elsif self.protocol_handler.start_with?("IBMPC/WIN_NT64")
          conn_params.architecture = :x64
          conn_params.platform = :windows        
        elsif self.protocol_handler.start_with?("Linuxi386/Linux")
          conn_params.architecture = :x86
          conn_params.platform = :linux
        elsif self.protocol_handler.start_with?("x86_64/Linux")
          conn_params.architecture = :x64
          conn_params.platform = :linux
        elsif self.protocol_handler.start_with?("Sun386i/SunOS")
          conn_params.architecture = :x86
          conn_params.platform = :solaris
        elsif self.protocol_handler.start_with?("AMD64/SunOS")
          conn_params.architecture = :x64
          conn_params.platform = :solaris          
        else
          raise Net::TTI::Exceptions::UnsupportedPlatform.new( self.protocol_handler )
        end
      end
    end
  end
end
