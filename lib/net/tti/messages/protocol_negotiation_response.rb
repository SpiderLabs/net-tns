module Net
  module TTI
    class ProtocolNegotiationResponse < Message
      handles_response_for_ttc_code TTC_CODE_PROTOCOL_NEGOTIATION

      # BinData fields
      uint8     :ttc_version
      # TODO throw if ttc_version is not in (4, 5, 6)
      uint8     :unknown1
      stringz   :ttc_server
      uint16le  :character_set
      uint8     :server_flags
      uint16le  :character_set_elements_length
      string    :character_set_elements,  :read_length => lambda {character_set_elements_length * 5}
      # TODO stop parsing here if ttc_version = 4
      uint16be  :fdo_length
      string    :fdo,  :read_length => :fdo_length
      # TODO stop parsing here is ttc_version < 6
      uint8     :server_compiletime_capabilities_length
      string    :server_compiletime_capabilities,  :read_length => :server_compiletime_capabilities_length
      uint8     :server_runtime_capabilities_length
      string    :server_runtime_capabilities,  :read_length => :server_runtime_capabilities_length

      def populate_connection_parameters( conn_params )
        conn_params.ttc_version = self.ttc_version
        conn_params.ttc_server = self.ttc_server
        conn_params.character_set = self.character_set
        conn_params.server_flags = self.server_flags
        conn_params.server_compiletime_capabilities = server_compiletime_capabilities
        conn_params.server_runtime_capabilities = server_runtime_capabilities

        ttc_server_map = {
          # (start of) protocol handler string => {params}
          "IBMPC/WIN_NT-" => {:architecture => :x86, :platform => :windows},
          "IBMPC/WIN_NT64" => {:architecture => :x64, :platform => :windows},
          "Linuxi386/Linux" => {:architecture => :x86, :platform => :linux},
          "x86_64/Linux" => {:architecture => :x64, :platform => :linux},
          "Sun386i/SunOS" => {:architecture => :x86, :platform => :solaris},
          "AMD64/SunOS" => {:architecture => :x64, :platform => :solaris},
        }

        ph_match, match_params = ttc_server_map.find do |ph_start, params|
          ttc_server.start_with?(ph_start)
        end

        if ph_match
          conn_params.architecture = match_params[:architecture]
          conn_params.platform = match_params[:platform]
        else
          raise Net::TTI::Exceptions::UnsupportedPlatform.new( ttc_server )
        end
      end
    end
  end
end
