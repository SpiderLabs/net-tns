require "net/tti/data_types"

module Net
  module TTI
    class Authentication < FunctionCall
      LOGON_MODE_PRE_AUTH   = 0x00000001
      LOGON_MODE_AUTH       = 0x00000101

      def self.create_pre_auth_request(target_architecture)
        case target_architecture
        when :x86
          return PreAuthenticationX86.new
        when :x64
          return PreAuthenticationX64.new
        else
          raise Net::TTI::Exceptions::UnsupportedPlatform.new(target_architecture)
        end
      end

      def self.create_auth_request(target_architecture)
        case target_architecture
        when :x86
          return AuthenticationX86.new
        when :x64
          return AuthenticationX64.new
        else
          raise Net::TTI::Exceptions::UnsupportedPlatform.new(target_architecture)
        end
      end

      def add_parameter( key, value, flags=0 )
        kvp = DataTypes::KeyValuePair.new( :kvp_key => key, :kvp_value => value, :flags => flags )
        self.parameters << kvp
      end

      def enc_client_session_key=(enc_client_session_key)
        add_parameter( "AUTH_SESSKEY", enc_client_session_key.tns_hexify.upcase, 1 )
      end

      def enc_password=(enc_password)
        add_parameter( "AUTH_PASSWORD", enc_password.tns_hexify.upcase )
      end
    end
  end
end
