module Net
  module TTI
    class DataTypeNegotiationRequest < Message
      # BinData fields

      # Not sure why this is duplicated, but clients always send the same
      # character set in both fields.
      # Character sets:
      #  0x00b2 (178) - US-ASCII
      #  0x0369 (873) - UTF-8
      uint16le  :charset1
      uint16le  :charset2
      
      string    :dty_body

      def _ttc_code()
        TTC_CODE_DATA_TYPE_NEGOTIATION
      end
      private :_ttc_code

      def self.create_request(platform)
        request = self.new
        request.character_set = 0x00b2
        request.dty_body = "4227060101010F010106010101010101017FFF030A030701017F017FFF01090101BF010506000107040702010000180003800000003C3C3C800000000000000ED007".tns_unhexify
        
        return request
      end

      def character_set=(charset)
        self.charset1 = charset
        self.charset2 = charset
      end
    end
  end
end
