require "net/tti/data_types"

module Net
  module TTI
    class PreAuthenticationResponse < Message
      uint8     :unknown1
      uint8     :parameter_count
      array     :parameters, :type => :key_value_pair, :read_until => lambda {index == parameter_count - 1}

      def _ttc_code
        return TTC_CODE_OK
      end
      private :_ttc_code

      def auth_sesskey
        param = find_param("AUTH_SESSKEY", true)
        return param.kvp_value.tns_unhexify
      end

      def auth_vfr_data
        param = find_param("AUTH_VFR_DATA", true)
        return param.kvp_value.tns_unhexify
      end

      def find_param(key, raise_if_not_found=false)
        param = self.parameters.find {|p| p.kvp_key == key}
        raise Net::TTI::Exceptions::TTIException.new("No #{key} parameter found") if param.nil? && raise_if_not_found
        return param
      end
      private :find_param
    end
  end
end
