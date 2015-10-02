
module Net
  module TTI
    class Capabilities
      def initialize(caps_bytes=[])
        @caps_bytes = caps_bytes
      end

      def self.from_byte_array(bytes)
        Capabilities.new(bytes)
      end

      def self.from_binary_string(string)
        Capabilities.new( string.unpack("C*") )
      end

      def [](index)
        @caps_bytes[index]
      end

      def []=(index, value)
        @caps_bytes[index] = value
      end

      def length
        @caps_bytes.length
      end

      def to_binary_s
        @caps_bytes.pack("C*")
      end

      # Returns hexified bytes, delimited by spaces
      # e.g. [0x01,0x41,0x81,0xa1] -> "01 41 81 a1"
      def to_hexified_s
        to_binary_s.scan(/../).join(" ")
      end
    end
  end
end
