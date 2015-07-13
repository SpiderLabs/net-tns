require "bindata"
require "net/tti/data_types/chunked_string"

module Net
  module TTI
    module DataTypes
      class KeyValuePair < BinData::Record
        # In earlier dialects, the 4 bytes before the strings appeared to contain
        # the total length of the string. In more recent dialects, this no longer
        # seems to be the case. However, a 32-bit null here still appears to
        # signal that there is no value.
        uint8        :unknown1, :value => 0x01
        uint8        :kvp_key_length, :value => lambda {kvp_key.length}
        chunked_string  :kvp_key, :onlyif => lambda {kvp_key_length != 0}
        uint8        :unknown2, :value => 0x01
        uint8        :kvp_value_length, :value => lambda {kvp_value.length}
        chunked_string  :kvp_value, :onlyif => lambda {kvp_value_length != 0}
        # flags are used when AUTH_SESSKEY and AUTH_ALTER_SESSION are sent to the server
        uint8        :flags_size,  :initial_value => 0x01, :onlyif => lambda {flags != 0}
        uint8        :flags,       :initial_value => 0x00

        def set(key, value)
          self.kvp_key.data = key
          self.kvp_value.data = value
        end
      end
    end
  end
end
