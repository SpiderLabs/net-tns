require "bindata"

module Net
  module TTI
    class Message < BinData::Record
      TTC_CODE_PROTOCOL_NEGOTIATION = 0x1
      TTC_CODE_DATA_TYPE_NEGOTIATION = 0x2
      TTC_CODE_FUNCTION_CALL = 0x3
      TTC_CODE_ERROR = 0x4
      TTC_CODE_OK = 0x8

      # BinData fields
      uint8     :ttc_code, :initial_value => :_ttc_code

      def _ttc_code
        raise NotImplementedError
      end
      private :_ttc_code

      def self.handles_response_for_ttc_code(ttc_code)
        @@ttc_classes ||= {}
        @@ttc_codes ||= {}
        if @@ttc_classes.has_key?(ttc_code)
          existing_class = @@ttc_classes[ttc_code]
          raise ArgumentError.new("Duplicate TTC response handlers defined: #{existing_class} and #{self} both have TTC code of #{ttc_code}")
        end

        @@ttc_classes[ttc_code] = self
        @@ttc_codes[self] = ttc_code
        return nil
      end

      def self.from_data_string( raw_message )
        ttc_code = raw_message[0].unpack("C").first

        unless message_class = @@ttc_classes[ ttc_code ]
          raise Net::TNS::Exceptions::TNSException.new( "Unknown TTC code: #{ttc_code}" )
        end

        new_message = message_class.new
        new_message.read( raw_message )

        return new_message
      end
    end
  end
end

require "pathname"
Dir.glob("#{Pathname.new(__FILE__).dirname}/messages/*.rb") { |file| require file }
