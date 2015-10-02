require "bindata"
require "net/tti/data_types/chunked_string"
require "net/tti/data_types/flags"

module Net
  module TTI
    module DataTypes
      class KeyValuePair < BinData::Record
        # Follows (simplified) format used by JDBC driver; other clients send
        # KVPs with a longer, more opaque structure (e.g. each chunked string
        # was preceded by a 4-byte value that, in earlier dialects appeared to
        # contain the total length of the string, but in later dialects did not
        # seem related to string length at all).
        uint8           :unknown1,         :initial_value => 0x01 # size in bytes of kvp_key_length OR boolean
        uint8           :kvp_key_length,   :onlyif => lambda {unknown1 != 0x00}, :value => lambda {kvp_key.length}
        chunked_string  :kvp_key,          :onlyif => lambda {unknown1 != 0x00 && kvp_key_length != 0x00}
        uint8           :unknown2,         :initial_value => 0x01 # size in bytes of kvp_value_length
        uint8           :kvp_value_length, :onlyif => lambda {unknown2 != 0x00}, :value => lambda {kvp_value.length}
        chunked_string  :kvp_value,        :onlyif => lambda {unknown2 != 0x00 && kvp_value_length != 0x00}
        # flags are used when AUTH_SESSKEY and AUTH_ALTER_SESSION are sent to the server
        flags        :flags
      end
    end
  end
end
