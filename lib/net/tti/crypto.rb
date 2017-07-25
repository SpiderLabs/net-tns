require 'openssl'

module Net::TTI
  class Crypto
    # Generates the encrypted password and encrypted client session key for
    # authentication with a 10g server.
    #
    # @param username [String] The username for authentication.
    # @param password [String] The password for authentication.
    # @param enc_server_session_key [String] The encrypted server session key.
    #   provided by the server. This should be a 32-byte binary packed string.
    # @return [Array<String>] The encrypted password and the encrypted client
    #   session key to use to authenticate with the server. These are returned
    #   as binary packed strings.
    def self.get_10g_auth_values( username, password, enc_server_session_key )
      # Hash the password and pad it to 16 bytes. This will be used as the key
      # for encrypting the client session key and decrypting the server session key.
      password_hash = hash_password_10g( username, password )
      password_hash += "\0" * 8

      # TODO: make random client session key
      client_session_key = "FAF5034314546426F329B1DAB1CDC5B8FF94349E0875623160350B0E13A0DA36".tns_unhexify

      # Encrypt client session key and decrypt the server session key, using the
      # password hash as a key.
      enc_client_session_key = openssl_encrypt( "AES-128-CBC", password_hash, nil,     client_session_key )
      server_session_key =     openssl_decrypt( "AES-128-CBC", password_hash, nil, enc_server_session_key )

      # Make the combined session key hash. This is used as the key to encrypt
      # the password.
      combo_session_key = create_combined_session_key_hash_10g( server_session_key, client_session_key )

      # TODO: make random salt
      salt = "4C31AFE05F3B012C0AE9AB0CDFF0C508".tns_unhexify
      # Encrypt the salted password
      enc_password = openssl_encrypt( "AES-128-CBC", combo_session_key, nil, salt + password, true )

      return enc_password, enc_client_session_key
    end

    # Generates the encrypted password and encrypted client session key for
    # authentication with an 11g server.
    #
    # @param password [String] The password for authentication.
    # @param enc_server_session_key [String] The encrypted server session key.
    #   provided by the server. This should be a 48-byte binary packed string.
    # @param auth_vfr_data [String] The value from the AUTH_VFR_DATA key-value
    #   pair provided by the server.
    # @return [Array<String>]  The encrypted password and the encrypted client
    #   session key to use to authenticate with the server. These are returned
    #   as binary packed strings.
    def self.get_11g_auth_values( password, enc_server_session_key, auth_vfr_data )
      # Hash the password and auth_vfr_data and pad it to 24 bytes. This will be
      # used as the key for encrypting the client session key and decrypting the
      # server session key.
      password_hash = sha1_digest( password + auth_vfr_data ) + ("\0" * 4)

      # TODO: make random client session key
      client_session_key = "080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808".tns_unhexify

      # Encrypt client session key and decrypt the server session key, using the
      # password hash as a key.
      enc_client_session_key = openssl_encrypt( "AES-192-CBC", password_hash, nil,     client_session_key )
      server_session_key =     openssl_decrypt( "AES-192-CBC", password_hash, nil, enc_server_session_key )

      # Make the combined session key hash. This is used as the key to encrypt
      # the password.
      combo_session_key = create_combined_session_key_hash_11g( server_session_key, client_session_key )

      # TODO: make random salt
      salt = "4C31AFE05F3B012C0AE9AB0CDFF0C508".tns_unhexify
      # Encrypt the salted password
      enc_password = openssl_encrypt( "AES-192-CBC", combo_session_key, nil, salt + password, true )

      return enc_password, enc_client_session_key
    end



    # Generates the password hash for use in 10g authentication.
    #
    # @param username [String] The username for authentication.
    # @param password [String] The password for authentication.
    # @return [String] The password hash, as a binary packed string.
    def self.hash_password_10g( username, password )
      uspw = (username + password).upcase().encode( Encoding::UTF_16BE )
      key = "0123456789abcdef".tns_unhexify   # fixed key used for 10g hashing

      # Pad the username-password to an 8-byte boundary
      if ( uspw.length % 4 > 0 )
        padding_length = 4 - ( uspw.length % 4 )
        uspw += ("\0".encode( Encoding::UTF_16BE )) * padding_length
      end

      key2 = openssl_encrypt( "DES-CBC", key, nil, uspw, false )
      key2 = key2[-8,8]

      pwhash = openssl_encrypt( "DES-CBC", key2, nil, uspw, false )
      pwhash = pwhash[-8,8]
    end

    # Generates the combined session key hash, for use in encrypting the
    # password in authentication.
    #
    # @param server_session_key [String] The unencrypted server session key, as
    #   a binary packed string.
    # @param client_session_key [String] The unencrypted client session key, as
    #   a binary packed string.
    # @return [String] The hash of the combined session key, as a binary packed
    #   string.
    def self.create_combined_session_key_hash_10g( server_session_key, client_session_key )
      # Unpack the session keys into byte arrays
      server_key_bytes = server_session_key.unpack( "C*" )
      client_key_bytes = client_session_key.unpack( "C*" )
      combo_session_key = ""

      # XOR bytes 17-32 of the session keys to make the combined session key
      for byte_itr in (16..31)
        combo_session_key += (server_key_bytes[ byte_itr ] ^ client_key_bytes[ byte_itr ]).chr
      end

      # Hash the combined session key
      return md5_digest( combo_session_key )
    end

    # Generates the combined session key hash, for use in encrypting the
    # password in authentication.
    #
    # @param server_session_key [String] The unencrypted server session key, as
    #   a binary packed string.
    # @param client_session_key [String] The unencrypted client session key, as
    #   a binary packed string.
    # @return [String] The hash of the combined session key, as a binary packed
    #   string.
    def self.create_combined_session_key_hash_11g( server_session_key, client_session_key )
      # make combined session key
      server_key_bytes = server_session_key.unpack( "C*" )
      client_key_bytes = client_session_key.unpack( "C*" )
      combo_session_key = ""
      for byte_itr in (16..39)
        combo_session_key += (server_key_bytes[ byte_itr ] ^ client_key_bytes[ byte_itr ]).chr
      end

      # hash combined session key
      combo_session_key = ( md5_digest(combo_session_key[0,16]) +
                            md5_digest(combo_session_key[16,combo_session_key.length]) )
      combo_session_key = combo_session_key[0,24]

      return combo_session_key
    end


    # Helper function for encryption.
    def self.openssl_encrypt( cipher, key, iv, data, padding=false )
      cipher = OpenSSL::Cipher.new( cipher )
      cipher.encrypt
      cipher.key = key
      cipher.iv = iv unless iv.nil?
      cipher.padding = 0 unless padding

      ciphertext = cipher.update( data ) + cipher.final
    end

    # Helper function for decryption.
    def self.openssl_decrypt( cipher, key, iv, data, padding=false )
      cipher = OpenSSL::Cipher.new( cipher )
      cipher.decrypt
      cipher.key = key
      cipher.iv = iv unless iv.nil?
      cipher.padding = 0 unless padding

      ciphertext = cipher.update( data ) + cipher.final
    end

    # @return the MD5 digest (as a binary string) for the given input string
    def self.md5_digest(input_str)
      digester=Digest::MD5.new()
      digester.update(input_str)
      return digester.digest
    end

    # @return the SHA1 digest (as a binary string) for the given input string
    def self.sha1_digest(input_str)
      digester=Digest::SHA1.new()
      digester.update(input_str)
      return digester.digest
    end
  end
end
