require "net/tti/data_types"

module Net
  module TTI
    class Authentication < FunctionCall
      LOGON_MODE_PRE_AUTH   = 0x01
      LOGON_MODE_AUTH       = 0x0101
      uint8     :unknown1,              :initial_value => 0x01
      uint8     :username_length_size,  :initial_value => 0x01
      uint8     :username_length,       :value => lambda { username.length }
      uint8     :logon_mode_size,       :initial_value => lambda { _logon_mode == Authentication::LOGON_MODE_PRE_AUTH ? 0x01: 0x02}
      choice    :logon_mode,            :selection => :_logon_mode do
        uint8    LOGON_MODE_PRE_AUTH,   :initial_value => lambda { _logon_mode }
        uint16le LOGON_MODE_AUTH,       :initial_value => lambda { _logon_mode }
      end
      uint8     :unused1,               :initial_value => 0x01
      uint8     :parameters_count_size, :initial_value => 0x01
      uint8     :parameters_count,      :value => lambda {parameters.count}
      uint8     :unused2,               :initial_value => 0x01
      uint8     :unused3,               :initial_value => 0x01      
      string    :username
      array     :parameters,   :type => :key_value_pair, :read_until => lambda {index == parameters_count - 1}

      def _function_code
        return FUNCTION_CODE_AUTH
      end
      private :_function_code

      def _logon_mode
        return Authentication::LOGON_MODE_AUTH
      end
      private :_logon_mode

      def self.create_pre_auth_request()
        return PreAuthentication.new
      end

      def self.create_auth_request()
        return Authentication.new
      end

      def add_parameter( key, value, flags=0 )
        kvp = DataTypes::KeyValuePair.new( :kvp_key => key, :kvp_value => value, :flags => flags )
        self.parameters << kvp
      end

      def enc_client_session_key=(enc_client_session_key)
        add_parameter( "AUTH_SESSKEY", enc_client_session_key.tns_hexify.upcase, 1)
      end

      def enc_password=(enc_password)
        add_parameter( "AUTH_PASSWORD", enc_password.tns_hexify.upcase )
      end
    end
    
    class PreAuthentication < Authentication
      def _function_code
        return FUNCTION_CODE_PRE_AUTH
      end
      private :_function_code

      def _logon_mode
        return Authentication::LOGON_MODE_PRE_AUTH
      end
      private :_logon_mode
    end
  end
end
