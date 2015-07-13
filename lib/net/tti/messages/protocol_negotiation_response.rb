module Net
  module TTI
    class ProtocolNegotiationResponse < Message
      handles_response_for_ttc_code TTC_CODE_PROTOCOL_NEGOTIATION

      # BinData fields
      uint8     :protocol_handler
      # TODO throw if proSvrVer is not in (4, 5, 6)
      uint8     :unused1
      stringz   :proSvrStr
      uint16le  :svrCharSet
      uint8     :svrFlags
      uint16le  :svrCharSetElem_length
      string    :svrCharSetElem,  :read_length => lambda {svrCharSetElem_length * 5}
      # TODO stop parsing here if proSvrVer = 4
      uint16be  :fdo_length
      string    :fdo,  :read_length => :fdo_length
      # TODO stop parsing here is proSvrVer < 6
      uint8     :svrCompiletimeCapabilities_length
      string    :svrCompiletimeCapabilities,  :read_length => :svrCompiletimeCapabilities_length
      uint8     :svrRuntimeCapabilities_length
      string    :svrRuntimeCapabilities,  :read_length => :svrRuntimeCapabilities_length

      def populate_connection_parameters( conn_params )
        conn_params.proSvrVer = self.proSvrVer
        conn_params.proSvrStr = self.proSvrStr
        conn_params.svrCharSet = self.svrCharSet
        conn_params.svrFlags = self.svrFlags
        conn_params.svrCompiletimeCapabilities = svrCompiletimeCapabilities
        conn_params.svrRuntimeCapabilities = svrRuntimeCapabilities

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
