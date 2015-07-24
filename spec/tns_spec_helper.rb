require "spec_helper"
require "net/tns"

require "net/tns/helpers/string_helpers"

module TnsSpecHelper
  SPEC_DIR = File.expand_path(File.dirname(__FILE__))
  MSGS_DIR = File.join(SPEC_DIR, 'net', 'tns', 'raw')

  def self.read_message(filename)
    File.open(File.join(MSGS_DIR, filename), "rb") {|f| f.read}
  end
end
