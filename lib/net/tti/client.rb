require "net/tti"
require "net/tns"

module Net
  module TTI
    class Client
      def connect(opts={})
        socket_opts = {}
        socket_opts_keys = [:host, :port, :new_socket_proc]
        socket_opts_keys.each {|key| socket_opts[key] = opts.delete(key) if opts.has_key?(key)}

        connect_opts = {}
        connect_opts_keys = [:sid, :service_name]
        connect_opts_keys.each {|key| connect_opts[key] = opts.delete(key) if opts.has_key?(key)}

        unless opts.empty?
          raise ArgumentError.new("Unrecognized #connect options: #{opts.keys.join(",")}")
        end

        begin
          @tti_conn = Net::TTI::Connection.new(socket_opts)
          @tti_conn.connect(connect_opts)
        rescue
          (@tti_conn.disconnect rescue nil) unless @tti_conn.nil?
          raise
        end
        Net::TTI.logger.info("TTI connection established. #{@tti_conn.conn_params}")
      end

      def authenticate( username, password )
        begin
          pre_auth_request = get_pre_auth_request( username )

          pre_auth_response_raw = @tti_conn.send_and_receive(pre_auth_request)
          pre_auth_response = PreAuthenticationResponse.read(pre_auth_response_raw)

          auth_request = get_auth_request(username, password, pre_auth_response)

          @tti_conn.send_and_receive(auth_request)
        rescue Exceptions::ErrorMessageReceived => error
          case error.error_code
          when 1017, 9275
            raise Exceptions::InvalidCredentialsError.new( error.message )
          when 28000
            raise Exceptions::AccountLockedOutError.new( error.message )
          when 28001
            raise Exceptions::PasswordExpiredError.new( error.message )
          when 28002
            # This is "password will expire in 7 days," i.e. a successful login
          else
            raise
          end
        end

        return true
      end

      def get_pre_auth_request(username)
        pre_auth_request = Authentication.create_pre_auth_request()
        pre_auth_request.username = username
        pre_auth_request.add_parameter("AUTH_TERMINAL", "unknown")
        return pre_auth_request
      end

      def get_auth_request(username, password, pre_auth_response)
        auth_sesskey = pre_auth_response.auth_sesskey

        case @tti_conn.conn_params.tns_version
        when Net::TNS::Version::VERSION_10G
          enc_password, enc_client_session_key = Net::TTI::Crypto.get_10g_auth_values( username, password, auth_sesskey )
        when Net::TNS::Version::VERSION_11G
          case auth_sesskey.length
          when 32
            enc_password, enc_client_session_key = Net::TTI::Crypto.get_10g_auth_values( username, password, auth_sesskey )
          when 48
            auth_vfr_data = pre_auth_response.auth_vfr_data
            enc_password, enc_client_session_key = Net::TTI::Crypto.get_11g_auth_values( password, auth_sesskey, auth_vfr_data )
          else
            raise Exceptions::ProtocolException.new("Unexpected AUTH_SESSKEY length #{auth_sesskey.length}")
          end
        else
          raise Exceptions::UnsupportedTNSVersion.new( @tti_conn.conn_params.tns_version )
        end

        auth_request = Authentication.create_auth_request()
        auth_request.username = username
        auth_request.enc_password = enc_password
        auth_request.enc_client_session_key = enc_client_session_key
        auth_request.add_parameter("AUTH_TERMINAL", "unknown")
        return auth_request
      end

      def disconnect
        @tti_conn.disconnect() unless @tti_conn.nil?
      end
    end
  end
end
