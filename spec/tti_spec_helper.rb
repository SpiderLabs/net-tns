require "spec_helper"
require "net/tti"

require "net/tns/helpers/string_helpers"

module TtiSpecHelper
  SPEC_DIR = File.expand_path(File.dirname(__FILE__))
  MSGS_DIR = File.join(SPEC_DIR, 'net', 'tti', 'raw')

  def self.read_message(filename)
    File.open(File.join(MSGS_DIR, filename), "rb") {|f| f.read}
  end
end
