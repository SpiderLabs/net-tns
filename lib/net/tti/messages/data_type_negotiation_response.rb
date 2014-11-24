module Net
  module TTI
    class DataTypeNegotiationResponse < Message
      handles_response_for_ttc_code TTC_CODE_DATA_TYPE_NEGOTIATION
      # BinData fields
      rest    :data
    end
  end
end
