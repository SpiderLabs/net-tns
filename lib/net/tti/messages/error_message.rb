module Net
  module TTI
    class ErrorMessage < Message
      handles_response_for_ttc_code TTC_CODE_ERROR

      # BinData fields

      uint8     :ucaeocs_length
      string    :ucaeocs,        :read_length => lambda { ucaeocs_length }
      uint8     :oerrdd_length
      string    :oerrdd,         :read_length => lambda { oerrdd_length }
      uint8     :current_row_number_length
      string    :current_row_number,  :read_length => lambda { current_row_number_length }
      uint8     :retcode_length
      string    :retcode,        :read_length => lambda { retcode_length }
      string    :unknown1,       :read_length => 24
      uint8     :message_length
      string    :message,         :read_length => lambda { message_length }
    end
  end
end
