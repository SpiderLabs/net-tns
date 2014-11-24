require "tti_spec_helper"
require "net/tti/crypto"

module Net::TTI
  describe Crypto do
    context "when doing general tests" do
      plaintext = "My voice is my passport. Verify me."
      key = "000102030405060708090A0B0C0D0F"

      context "when using AES-128-CBC" do
        it "should encrypt and decrypt to the original value" do
          ciphertext = Crypto.openssl_encrypt( "AES-128-CBC", key, nil, plaintext, true )
          decrypted_text = Crypto.openssl_decrypt( "AES-128-CBC", key, nil, ciphertext, true )
          expect(decrypted_text).to eql( plaintext )
        end
      end

      context "when using AES-192-CBC" do
        it "should encrypt and decrypt to the original value" do
          ciphertext = Crypto.openssl_encrypt( "AES-192-CBC", key, nil, plaintext, true )
          decrypted_text = Crypto.openssl_decrypt( "AES-192-CBC", key, nil, ciphertext, true )
          expect(decrypted_text).to eql( plaintext )
        end
      end

      context "when using DES-CBC" do
        it "should encrypt and decrypt to the original value" do
          ciphertext = Crypto.openssl_encrypt( "DES-CBC", key, nil, plaintext, true )
          decrypted_text = Crypto.openssl_decrypt( "DES-CBC", key, nil, ciphertext, true )
          expect(decrypted_text).to eql( plaintext )
        end
      end
    end

    context "when performing individual steps" do
      context "when calculating a known 10g hash" do
        username_password = "00530059005300540045004d004d0041004e0041004700450052000000000000".tns_unhexify
        key1 = "0123456789abcdef".tns_unhexify
        key2_full_known = "643624edc5fea9b402b0b017e7cb7db713108ac1914e984fe2eddfe949a0c3c1".tns_unhexify
        pwhash_full_known = "a2295a85f9b413c2d2b25971d5199a0ba6c4c6035a4906b2d4df7931ab130e37".tns_unhexify

        it "should calculate the second-stage key" do
          key2_full = Crypto.openssl_encrypt( "DES-CBC", key1, nil, username_password, false )
          expect(key2_full).to eql( key2_full_known )
        end

        it "should calculate the un-truncated password hash" do
          pwhash_full = Crypto.openssl_encrypt( "DES-CBC", key2_full_known[-8,8], nil, username_password, false )
          expect(pwhash_full).to eql( pwhash_full_known )
        end
      end

      context "when calculating a known 10g hash #2" do
        username_password = "00530059005300540045004d004d0041004e0041004700450052000000000000".tns_unhexify
        key1 = "0123456789abcdef".tns_unhexify
        key2_full_known = "643624edc5fea9b402b0b017e7cb7db713108ac1914e984fe2eddfe949a0c3c1".tns_unhexify
        pwhash_full_known = "a2295a85f9b413c2d2b25971d5199a0ba6c4c6035a4906b2d4df7931ab130e37".tns_unhexify

        it "should calculate the second-stage key" do
          key2_full = Crypto.openssl_encrypt( "DES-CBC", key1, nil, username_password, false )
          expect(key2_full).to eql( key2_full_known )
        end

        it "should calculate the un-truncated password hash" do
          pwhash_full = Crypto.openssl_encrypt( "DES-CBC", key2_full_known[-8,8], nil, username_password, false )
          expect(pwhash_full).to eql( pwhash_full_known )
        end
      end

      # These are real-world values pulled off the wire. We'd better be able to
      # handle them correctly.
      context "when handling known session key values" do

        context "for Oracle 9i" do
          it "should decrypt session key 1" do
            sesion_key_enc = "8cf28b36e4f3d2095729cf59510003bf".tns_unhexify
            session_key_known     = "d3e11aa692f9e9f14c274c661228de1c".tns_unhexify
            key             = "8cea3ba0903a2a8fea55807f2495062c5b2286a13baefee9".tns_unhexify
            iv              = "8020400408021001".tns_unhexify

            session_key = Crypto.openssl_decrypt( "DES-EDE3-CBC", key, iv, sesion_key_enc, false )
            expect(session_key).to eql( session_key_known )
          end
        end

        context "for Oracle 10g/11g" do
          pwhash = "d4df7931ab130e370000000000000000".tns_unhexify

          it "should decrypt session key 1" do
            sesion_key_enc = "ab629dc2f03cde859ca5da438054ea59e064f0e8ba52b5541d4d8e9b437cb8eb".tns_unhexify
            session_key_known     = "68d830ededbdc241480851a3348185929c4cb7a15deb5faa2f98374a51271501".tns_unhexify

            session_key = Crypto.openssl_decrypt( "AES-128-CBC", pwhash, nil, sesion_key_enc, false )
            expect(session_key).to eql( session_key_known )
          end

          it "should decrypt session key 2" do
            sesion_key_enc = "6B9506EE2E960C1B4870152C4B8D24D7706791F8F205B185C8AD26D93AA9CBA9".tns_unhexify
            session_key_known     = "0F36690EE57A8156AF82428295654841F4EFA9851ADF6DF288A54FE111F139C9".tns_unhexify

            session_key = Crypto.openssl_decrypt( "AES-128-CBC", pwhash, nil, sesion_key_enc, false )
            expect(session_key).to eql( session_key_known )
          end

          it "should decrypt session key 3" do
            sesion_key_enc = "899883f8ee71e1e6dd8f96d0df3422ca1c5b566be458e047bb67eec1e36186df".tns_unhexify
            session_key_known     = "C3C641EC9CFD76606488CF01B1BBF86D8AA7EE36523848AADB8CB36CDC85FE59".tns_unhexify

            session_key = Crypto.openssl_decrypt( "AES-128-CBC", pwhash, nil, sesion_key_enc, false )
            expect(session_key).to eql( session_key_known )
          end

          it "should encrypt session key 1" do
            session_key_enc_known = "37933e0e2d57332c89f74a00eed13fb0e14a47c5d79e54919dc12f249a9f950c".tns_unhexify
            session_key     = "FAF5034314546426F329B1DAB1CDC5B8FF94349E0875623160350B0E13A0DA36".tns_unhexify

            session_key_enc = Crypto.openssl_encrypt( "AES-128-CBC", pwhash, nil, session_key, false )
            expect(session_key_enc).to eql( session_key_enc_known )
          end

          it "should encrypt session key 2" do
            session_key_enc_known = "d321b6e4c7b3174f21afb7fd73bdd3116f9407feb475820a89429063a6e8f0a9".tns_unhexify
            session_key     = "4C31AFE05F3B012C0AE9AB0CDFF0C5084C31AFE05F3B012C0AE9AB0CDFF0C508".tns_unhexify

            session_key_enc = Crypto.openssl_encrypt( "AES-128-CBC", pwhash, nil, session_key, false )
            expect(session_key_enc).to eql( session_key_enc_known )
          end
        end
      end

      context "when encrypting passwords" do
        context "for Oracle 9i" do
          it "should encrypt password 1" do
            password_obf = "80789358776f7264396cfa1270617373".tns_unhexify
            password_enc_known = "3078d7de44385654cc952a9c56e2659b".tns_unhexify
            key          = "31b22dc665e423e03a88c112c3a09c81487458df684897d1e9749cfe8d4704f828f642bde4abf5ca".tns_unhexify
            iv           = "8020400408021001".tns_unhexify

            password_enc = Crypto.openssl_encrypt( "DES-EDE3-CBC", key, iv, password_obf, true )
            expect(password_enc[0,16]).to eql( password_enc_known )
          end
        end

        context "for Oracle 10g/11g" do
          it "should encrypt password 1" do
            combined_session_key = "906b64b47d8e6e97751b90c4b9776e55".tns_unhexify
            salted_password = "4c31afe05f3b012c0ae9ab0cdff0c5084d414e41474552".tns_unhexify
            password_enc_known = "8D061272A71886AB5F148F4BA3FB74D3BA88C6C19568760DDFB100BFA7585B58".tns_unhexify

            password_enc = Crypto.openssl_encrypt( "AES-128-CBC", combined_session_key, nil, salted_password, true )
            expect(password_enc).to eql( password_enc_known )
          end
        end
      end
    end


    context "calling hash_password_10g" do
      it "should return the correct hash for SYSTEM/MANAGER" do
        hash = Crypto.hash_password_10g( "SYSTEM", "MANAGER" )
        expect(hash.tns_hexify).to eql( "d4df7931ab130e37" )
      end

      it "should return the correct hash for SYSTEM/SYSTEM" do
        hash = Crypto.hash_password_10g( "SYSTEM", "SYSTEM" )
        expect(hash.tns_hexify).to eql( "970baa5b81930a40" )
      end

      it "should convert the username and password to upper-case before hashing" do
        hash1 = Crypto.hash_password_10g( "sYsTeM", "mAnAgEr" )
        hash2 = Crypto.hash_password_10g( "SYSTEM", "MANAGER" )
        expect(hash1.tns_hexify).to eql( hash2.tns_hexify )
      end
    end

    context "calling get_10g_auth_values" do
      server_session_key_enc = "07A7223BEA0D24CCB1A9ADB947F82E34268A00A153053015CC246F83B1C72CB0".tns_unhexify
      # The encrypted client session key depends (obviously) on knowing the value of the client session key.
      # Currently, a static value is used. If this value were changed or made to be randomly generated, this
      # spec would break.
      client_session_key_enc = "17168F8A0A7D2827A8F4764A27627D95F5A07011E74602A2289F908B94FB8BC6".tns_unhexify
      # Ditto for the salt used here
      password_enc =           "EAE776A214983E76926B231E8FD135DBCC73E6136B7E1332548C4AA2A554DF02".tns_unhexify

      enc_password, enc_client_session_key = Crypto.get_10g_auth_values( "system", "system", server_session_key_enc )

      it "should return the correct encrypted password" do
        expect(enc_password).to eql( password_enc )
      end
      it "should return the correct encrypted client session key" do
        expect(enc_client_session_key).to eql( client_session_key_enc )
      end
    end

    context "calling get_11g_auth_values" do
      server_session_key_enc = "78c14513e9338ae8203d3a4a0354caca7b5e5db5d8664f5f979082fd16458eece8c8dc073addfea80c4aaec9d2988a32".tns_unhexify
      auth_vfr_data =          "6af5bdb421e874f78625".tns_unhexify
      # The encrypted client session key depends (obviously) on knowing the value of the client session key.
      # Currently, a static value is used. If this value were changed or made to be randomly generated, this
      # spec would break.
      client_session_key_enc = "42B677AE69DAF917C6B87E8AE384F59A9475E7EFD41683188DF4EF24866615B1E2759BE8343F476711E14D0B71C48549".tns_unhexify
      # Ditto for the salt used here
      password_enc =           "F9E7B726CB1FC85A81A1E8590C705A7CCA45F8A4E1A0F3110D3C7CE531862E6A".tns_unhexify

      enc_password, enc_client_session_key = Crypto.get_11g_auth_values( "admin", server_session_key_enc, auth_vfr_data )

      it "should return the correct encrypted password" do
        expect(enc_password).to eql( password_enc )
      end
      it "should return the correct encrypted client session key" do
        expect(enc_client_session_key).to eql( client_session_key_enc )
      end
    end
  end
end
