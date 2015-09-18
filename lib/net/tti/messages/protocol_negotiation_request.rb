module Net
  module TTI
    class ProtocolNegotiationRequest < Message
      # BinData fields
      # In the request, this will be the version(s) the client supports; in the
      # response, this will be the version the server chooses. These are a
      # concatenated string of version numbers (e.g. 060504).
      stringz   :client_versions_string
      stringz   :client_string

      def _ttc_code
        TTC_CODE_PROTOCOL_NEGOTIATION
      end
      private :_ttc_code

      def self.create_request(client_versions=[6, 5, 4, 3, 2, 1, 0], client_string = "Java_TTC-8.2.0")
        request = self.new
        request.client_versions = client_versions
        request.client_string = client_string

        return request
      end

      def client_versions=(versions)
        self.client_versions_string = versions.pack("C*")
      end
    end
  end
end
