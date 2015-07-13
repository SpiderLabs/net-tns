module Net
  module TTI
    class ProtocolNegotiationResponse < Message
      handles_response_for_ttc_code TTC_CODE_PROTOCOL_NEGOTIATION

      # BinData fields
      uint8     :proSvrVer
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

        case self.proSvrStr[0,13]
        when "IBMPC/WIN_NT-"
          conn_params.architecture = :x86
          conn_params.platform = :windows
        when "IBMPC/WIN_NT6"
          conn_params.architecture = :x64
          conn_params.platform = :windows
        when "Linuxi386/Lin"
          conn_params.architecture = :x86
          conn_params.platform = :linux
        when "x86_64/Linux "
          conn_params.architecture = :x64
          conn_params.platform = :linux
        when "AMD64/SunOS-4"
          conn_params.architecture = :x64
          conn_params.platform = :solaris
        when "Sun386i/SunOS"
          conn_params.architecture = :x86
          conn_params.platform = :solaris        
        else
          raise Net::TTI::Exceptions::UnsupportedPlatform.new( self.proSvrStr )
        end               
      end
    end
  end
end
