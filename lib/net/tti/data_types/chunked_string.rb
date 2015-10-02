require "bindata"

module Net
  module TTI
    module DataTypes
      class ChunkedString < BinData::BasePrimitive
        # The marker to indicate that a string is being divided into multiple chunks
        MULTI_CHUNK_MARKER = 0xFE
        MULTI_CHUNK_TERMINATOR = 0x00
        # The apparent maximum chunk length used by Oracle TNS implementations
        MAX_CHUNK_LENGTH = 0x40

        def sensible_default
          return ""
        end

        def read_and_return_value(io)
          begin
            length = unmarshal_uint8(io)
          rescue EOFError
            return ""
          end

          if length == MULTI_CHUNK_MARKER
            data = ""
            while (length = unmarshal_uint8(io)) != MULTI_CHUNK_TERMINATOR
              data += io.readbytes(length)
            end

            return data
          else
            return io.readbytes(length)
          end
        end

        def value_to_binary_string(value)
          return "" if value.empty?

          if value.length > MAX_CHUNK_LENGTH
            value_index = 0

            binary_string = ""
            binary_string << [MULTI_CHUNK_MARKER].pack("C")
            while value_index < value.length
              chunk = value[value_index, MAX_CHUNK_LENGTH]
              binary_string << [chunk.length, chunk].pack("Ca*")
              value_index += MAX_CHUNK_LENGTH
            end
            binary_string << [MULTI_CHUNK_TERMINATOR].pack("C")
            return binary_string
          else
            return [value.length, value].pack("Ca*")
          end
        end

        private
        def unmarshal_uint8(io)
          int_string = io.readbytes(1)
          return int_string.unpack("C").first
        end
      end
    end
  end
end
