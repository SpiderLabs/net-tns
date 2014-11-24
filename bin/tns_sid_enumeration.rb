#!/usr/bin/env ruby

require "net/tns"
require "set"

if (ARGV.size < 1 or ARGV[0] == '-h')
  STDERR.puts("Usage: #{File.basename $0} host [port]")
  exit 1
end

@conn_opts = {}
@conn_opts[:host] = ARGV.shift
port = ARGV.shift
@conn_opts[:port] = port.to_i unless port.nil?

def valid_sid?(name)
  begin
    conn = Net::TNS::Connection.new(@conn_opts)
    conn.connect(:sid=>name)
    return true
  rescue Net::TNS::Exceptions::RefuseMessageReceived
  ensure
    conn.disconnect() if conn
  end
  return false
end


dictionary = [
  "ORCL",
  "ORACLE",
  "ORADB",
  "XE",
  "TEST",
  "PLSExtProc",
]

sids = Set.new
begin
  dictionary.each do |name|
    sids << name if valid_sid?(name)
  end

ensure
  unless sids.empty?
    puts "SIDs:\n  " + sids.to_a.join("\n  ")
  end

  if sids.empty?
    puts "No valid SIDs found"
  end
end
