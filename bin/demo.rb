require "net/tns"
require "net/tti"
tti_client = Net::TTI::Client.new
tti_client.connect( :host => "utsol1.slab.prv", :sid => "orcl10g2" )
begin
  tti_client.authenticate( "system", "admin123" )
  puts "Successfully connected."
rescue Net::TTI::Exceptions::InvalidCredentialsError
  puts "Wrong credentials."
end
tti_client.disconnect