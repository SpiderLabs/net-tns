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

        protocol_handler_map = {
          # (start of) protocol handler string => {params}
          "IBMPC/WIN_NT-" => {:architecture => :x86, :platform => :windows},
          "IBMPC/WIN_NT64" => {:architecture => :x64, :platform => :windows},
          "Linuxi386/Linux" => {:architecture => :x86, :platform => :linux},
          "x86_64/Linux" => {:architecture => :x64, :platform => :linux},
          "Sun386i/SunOS" => {:architecture => :x86, :platform => :solaris},
          "AMD64/SunOS" => {:architecture => :x64, :platform => :solaris},
        }

        ph_match, match_params = protocol_handler_map.find do |ph_start, params|
          protocol_handler.start_with?(ph_start)
        end

        if ph_match
          conn_params.architecture = match_params[:architecture]
          conn_params.platform = match_params[:platform]
        else
          raise Net::TTI::Exceptions::UnsupportedPlatform.new( protocol_handler )
        end
      end
    end
  end
end
