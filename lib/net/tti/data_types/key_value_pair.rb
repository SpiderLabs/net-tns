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
        uint32le        :unknown1, :value => lambda {kvp_key.length}
        chunked_string  :kvp_key, :onlyif => lambda {unknown1 != 0}
        uint32le        :unknown2, :value => lambda {kvp_value.length}
        chunked_string  :kvp_value, :onlyif => lambda {unknown2 != 0}
        uint32le        :flags

        def set(key, value)
          self.kvp_key.data = key
          self.kvp_value.data = value
        end
      end
    end
  end
end
