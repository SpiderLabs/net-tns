#!/usr/bin/env ruby

require "net/tns"
require "set"

if (ARGV.size < 1 or ARGV[0] == '-h')
  STDERR.puts("Usage: #{File.basename $0} host [port]")
  exit 1
end

opts = {}
opts[:host] = ARGV.shift
port = ARGV.shift
opts[:port] = port.to_i unless port.nil?

begin
  sids = Set.new
  service_names = Set.new

  status_raw = Net::TNS::Client.get_status(opts)
  status_raw.scan(/(INSTANCE|SERVICE)_NAME=([^\)]+)/).each do |type, name|
    case type
    when "INSTANCE"
      sids << name
    when "SERVICE"
      service_names << name
    end
  end

  unless sids.empty?
    puts "SIDs:\n  " + sids.to_a.join("\n  ")
  end

  unless service_names.empty?
    puts "Service Names:\n  " + service_names.to_a.join("\n  ")
  end

  if sids.empty? && service_names.empty?
    puts "No SIDs or service names received."
  end
rescue Net::TNS::Exceptions::RefuseMessageReceived
  warn "Server refused the request"
end
