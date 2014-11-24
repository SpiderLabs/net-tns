#!/usr/bin/env ruby

require "net/tns"

if (ARGV.size < 1 or ARGV[0] == '-h')
  STDERR.puts("Usage: #{File.basename $0} host [port]")
  exit 1
end

opts = {}
opts[:host] = ARGV.shift
port = ARGV.shift
opts[:port] = port.to_i unless port.nil?

puts Net::TNS::Client.get_version(opts)
