require "bindata"

module Net
  module TTI
    module DataTypes
      class Flags < BinData::Primitive
        uint8 :value_length
        choice :flag_value, :selection => :value_length do
          virtual  0, :value => 0
          uint8    1
          uint16be 2
          uint32be 4
        end

        def get
          self.flag_value.to_i
        end

        def set(new_value)
          if new_value > 0xffff
            self.value_length = 4
            self.flag_value = new_value
          elsif new_value > 0xff
            self.value_length = 2
            self.flag_value = new_value
          elsif new_value > 0
            self.value_length = 1
            self.flag_value = new_value
          else
            self.value_length = 0
          end
        end
      end
    end
  end
end
