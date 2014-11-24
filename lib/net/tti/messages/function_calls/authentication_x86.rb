require_relative "authentication"

module Net
  module TTI
    class AuthenticationX86 < Authentication
      # Clients seem to change this without any effect on the server. It looks
      # like it's probably 4 8-bit values, but if we're ignoring them all, we
      # can ignore them as one structure
      uint32le  :unknown2,         :initial_value => 0xFFFFFFFE
      # Some Oracle clients instead send username.length*3 here to 11g servers,
      # but it doesn't seem to matter
      uint32le  :unknown3,         :value => lambda { username.length }
      # 0x1 => preauth, 0x101 => auth
      uint32le  :logon_mode,       :initial_value => :_logon_mode
      # Ditto for unknown2. Oracle clients put the same value into the upper
      # 16 bits of unknown4, unknown5 and unknown6 in each request, but I can't
      # figure out its meaning
      uint32le  :unknown4,         :initial_value => 0xFFFFFFFE
      uint32le  :parameter_count,  :value => lambda {parameters.count}
                # See unknown4
      uint32le  :unknown5,         :initial_value => 0xFFFFFFFE
      uint32le  :unknown6,         :initial_value => 0xFFFFFFFE
      # username_length and username might be a chunked string, but we
      # don't need to worry about chunking since Oracle usernames can't
      # be longer than 30 characters
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

    class PreAuthenticationX86 < AuthenticationX86
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
