module Net
  module TTI
    class FunctionCall < Message
      handles_response_for_ttc_code TTC_CODE_FUNCTION_CALL

      FUNCTION_CODE_PRE_AUTH = 0x76
      FUNCTION_CODE_AUTH = 0x73

      # BinData fields
      # The function code: 0x76 => preauth, 0x73 => auth
      uint8     :function_code, :initial_value => :_function_code
      uint8     :sequence_number, :initial_value => :_sequence_number

      def _ttc_code
        return TTC_CODE_FUNCTION_CALL
      end
      private :_ttc_code

      def _function_code
        raise NotImplementedError
      end
      private :_function_code

      def _sequence_number
        @@seq_num ||= 0
        @@seq_num += 1
        return @@seq_num
      end
      private :_sequence_number

      def to_binary_s
        if sequence_number == 0
          sequence_number = FunctionCall.next_sequence_number
        end

        super
      end

      def self.next_sequence_number
        @@last_sequence_number ||= 0
        @@last_sequence_number = (@@last_sequence_number + 1) % 256
        return @@last_sequence_number
      end
    end
  end
end

require "pathname"
Dir.glob("#{Pathname.new(__FILE__).dirname}/function_calls/*.rb") { |file| require file }
