require "bindata"
require "net/tti/data_types/chunked_string"

module Net
  module TTI
    module DataTypes
      class FlagInt < BinData::Primitive
        uint8 :len
        choice :value2, :selection => :len do
          virtual  0, :value => 0
          uint8    1
          uint16be 2
          uint32be 4
        end

        def get
          self.value2.to_i
        end

        def set(v)
          if v > 0xffff
            self.len = 4
            self.value2 = v
          elsif v > 0xff
            self.len = 2
            self.value2 = v
          elsif v > 0
            self.len = 1
            self.value2 = v
          else
            self.len = 0
          end
        end
      end
    
      class KeyValuePair < BinData::Record
        # Based on Oracle JDBC 10g driver implementation
        uint8           :unknown1,         :initial_value => 0x01 # size in bytes of kvp_key_length OR boolean
        uint8           :kvp_key_length,   :onlyif => lambda {unknown1 != 0x00}, :value => lambda {kvp_key.length}
        chunked_string  :kvp_key,          :onlyif => lambda {unknown1 != 0x00 && kvp_key_length != 0x00}
        uint8           :unknown2,         :initial_value => 0x01 # size in bytes of kvp_value_length
        uint8           :kvp_value_length, :onlyif => lambda {unknown2 != 0x00}, :value => lambda {kvp_value.length}
        chunked_string  :kvp_value,        :onlyif => lambda {unknown2 != 0x00 && kvp_value_length != 0x00}
        # flags are used when AUTH_SESSKEY and AUTH_ALTER_SESSION are sent to the server
        flag_int        :flags
      end
    end
  end
end
