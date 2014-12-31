module Net::TNS
  # This module includes common string helper methods for monkey-patching
  # or mixing-in to string objects.
  module StringHelpers
    HEXCHARS = [("0".."9").to_a, ("a".."f").to_a].flatten

    #From the Ruby Black Bag (http://github.com/emonti/rbkb/)
    # Convert a string to ASCII hex string. Supports a few options for format:
    #
    # :delim - delimter between each hex byte
    # :prefix - prefix before each hex byte
    # :suffix - suffix after each hex byte
    #
    def tns_hexify(opts={})
      delim = opts[:delim]
      pre = (opts[:prefix] || "")
      suf = (opts[:suffix] || "")

      if (rx=opts[:rx]) and not rx.kind_of? Regexp
        raise ArgumentError.new("rx must be a regular expression")
      end

      out=Array.new

      self.each_byte do |c|
        hc = if (rx and not rx.match c.chr)
               c.chr
             else
               pre + (HEXCHARS[(c >> 4)] + HEXCHARS[(c & 0xf )]) + suf
             end
        out << (hc)
      end
      out.join(delim)
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
