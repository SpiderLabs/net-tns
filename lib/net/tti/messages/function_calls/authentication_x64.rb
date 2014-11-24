require_relative "authentication"

module Net
  module TTI
    class AuthenticationX64 < Authentication
      uint32le  :unknown2,         :initial_value => 0x00001201
      uint8     :unknown3,         :initial_value => 0x00
      uint32le  :logon_mode,       :initial_value => :_logon_mode
      uint8     :unknown4,         :initial_value => 0x01
      uint32le  :parameter_count,  :value => lambda {parameters.count}
      uint16le  :unknown5,         :initial_value => 0x0101
      # username_length and username might be a chunked string, but we
      # don't need to worry about chunking since Oracle usernames can't
      # be longer than 30 characters.
      uint8     :username_length,  :value => lambda { username.length }
      string    :username
      array     :parameters, :type => :key_value_pair, :read_until => lambda {index == parameter_count-1}

      def _function_code
        return FUNCTION_CODE_AUTH
      end
      private :_function_code

      def _logon_mode
        return Authentication::LOGON_MODE_AUTH
      end
      private :_logon_mode
    end

    class PreAuthenticationX64 < AuthenticationX64
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
