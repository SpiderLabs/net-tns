module Net
  module TTI
    class ErrorMessage < Message
      handles_response_for_ttc_code TTC_CODE_ERROR

      # BinData fields
      
      # if ServerCompileTimeCapability[15] & 1 == 1 then 
      #   int ucaeocs = unmarshalUB4()
      #   if (ucaeocs & 8) != 0
      #     discardTime = unmarshalSB8()
      # if TTCVersion() >= 3
      #   endToEndECIDSequenceNumber = unmarshalUB2()
      # curRowNumber = unmarshalUB4();
      # retCode = unmarshalUB2();
      # ...
      # Improve this code by using @tti_conn.conn_params.tns_version and ServerCompileTimeCapabilities

      uint8     :ucaeocs_size
      string    :ucaeocs,        :read_length => lambda { ucaeocs_size }
      uint8     :oerrdd_size
      string    :oerrdd,         :read_length => lambda { oerrdd_size }
      uint8     :currownumber_size
      string    :currownumber,   :read_length => lambda { currownumber_size }
      uint8     :retcode_size
      string    :retcode,        :read_length => lambda { retcode_size }
      string    :horrible_not_parsed_part, :read_length => 24
      uint8     :message_length
      string    :message,         :read_length => lambda { message_length }
    end
  end
end
