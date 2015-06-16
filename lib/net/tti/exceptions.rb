module Net::TTI
  module Exceptions
    class TTIException < StandardError
    end

    class ProtocolException < TTIException
    end

    class UnsupportedTarget < TTIException
    end

    class UnsupportedArchitecture < TTIException
      def initialize( architecture )
        super( "Unsupported architecture: #{architecture}" )
      end
    end

    class UnsupportedPlatform < UnsupportedTarget
      def initialize( platform )
        super( "Unsupported platform: #{platform}" )
      end
    end

    class UnsupportedTNSVersion < UnsupportedTarget
      def initialize( version )
        super( "Unsupported version: #{version}" )
      end
    end



    class ErrorMessageReceived < TTIException
      ERROR_REGEX = /ORA\-(\d+)(?:\:\ (.*))?/
      ERROR_REGEX_INDEX_CODE = 1
      ERROR_REGEX_INDEX_DESCRIPTION = 2

      # Attempts to parse and return the "ORA-xxxxx" error code from the error message
      # @return [Integer] A numeric error code, or nil if the code could not be determined
      def error_code()
        matches = ERROR_REGEX.match( self.message )
        error_code = matches[ERROR_REGEX_INDEX_CODE] unless( matches.nil? or matches[ERROR_REGEX_INDEX_CODE].nil? )
        error_code = error_code.to_i unless error_code.nil?
        return error_code
      end


      # Attempts to parse and return the error description after the "ORA-xxxxx"
      # error code in the error message
      # @return [String] A string containing the error description, or nil if the description could not be determined
      def error_description()
        matches = ERROR_REGEX.match( self.message )
        return matches[ERROR_REGEX_INDEX_DESCRIPTION] unless( matches.nil? or matches[ERROR_REGEX_INDEX_DESCRIPTION].nil? )
      end
    end

    class AuthenticationError < ErrorMessageReceived
    end

    class InvalidCredentialsError < AuthenticationError
    end

    class AccountLockedOutError < AuthenticationError
    end

    class PasswordExpiredError < AuthenticationError
    end
  end
end
