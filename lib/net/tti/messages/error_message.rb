module Net
  module TTI
    class ErrorMessage < Message
      handles_response_for_ttc_code TTC_CODE_ERROR

      # BinData fields
      string    :unknown1,        :read_length => 6
      uint16le  :unknown2
      string    :unknown3,        :read_length => lambda { unknown2 == 0x01 ? 87 : 57 }
      uint8     :message_length
      string    :message,         :read_length => lambda { message_length }
    end
  end
end
