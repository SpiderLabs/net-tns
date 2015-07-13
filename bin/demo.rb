require "net/tns"
require "net/tti"
tti_client = Net::TTI::Client.new
tti_client.connect( :host => "hostname", :sid => "sid" )
begin
  tti_client.authenticate( "account", "password" )
  puts "Successfully connected."
rescue Net::TTI::Exceptions::InvalidCredentialsError
  puts "Wrong credentials."
end
tti_client.disconnect