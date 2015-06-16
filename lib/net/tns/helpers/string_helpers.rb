module Net::TNS
  # This module includes common string helper methods for monkey-patching
  # or mixing-in to string objects.
  module StringHelpers
    HEXCHARS = [("0".."9").to_a, ("a".."f").to_a].flatten

    # Adapted from the Ruby Black Bag (http://github.com/emonti/rbkb/)
    # Convert a string to ASCII hex string
    def tns_hexify
      self.each_byte.map do |byte|
        (HEXCHARS[(byte >> 4)] + HEXCHARS[(byte & 0xf )])
      end.join()
    end

    # Convert ASCII hex string to raw.
    #
    # Parameters:
    #
    #   d = optional 'delimiter' between hex bytes (zero+ spaces by default)
    def tns_unhexify(d=/\s*/)
      self.strip.gsub(/([A-Fa-f0-9]{1,2})#{d}?/) { $1.hex.chr }
    end
  end
end

class String
  include Net::TNS::StringHelpers
end
